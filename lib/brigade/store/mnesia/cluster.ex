defmodule Brigade.Store.Mnesia.Cluster do
  @moduledoc """
  Cluster-aware Mnesia bootstrap: joins this node's RAM store to the mesh so the
  `:brigade_vms` / `:brigade_hosts` tables are genuinely replicated, not
  node-local.

  Mnesia does **not** auto-replicate `ram_copies` tables when Erlang nodes
  connect. Replication is established explicitly, here, at join time:

    1. `:mnesia.change_config(:extra_db_nodes, peers)` merges this node's in-RAM
       schema with its peers' (skipped when there are no peers).
    2. Under a cluster-wide `:global.trans` lock, exactly one node ever *creates*
       each table; every other node *adds a local `ram_copies` copy* of the
       already-merged table. Local copies keep reads/writes local and let the
       data survive a peer dying (the singleton scheduler may re-home here).

  This module is a long-lived GenServer so it can re-join on `:nodeup` — late
  joins (async libcluster) and node restarts are handled the same way as the
  boot-time join, so correctness does not depend on supervision-tree ordering
  relative to libcluster.

  ## Out of scope

  Netsplit **healing** is not handled. Rejoining two independently-populated
  partitions is a genuine Mnesia merge conflict (`:merge_schema_failed` /
  `running_partitioned_network`) that Mnesia will not silently resolve and that
  may need operator intervention (`:mnesia.set_master_nodes/2`). Deferred to
  M3/M4. The scheduler quorum gate (`min_cluster_size`) already stops a minority
  partition from *placing* VMs, which bounds divergence.
  """
  use GenServer
  require Logger

  @vms :brigade_vms
  @hosts :brigade_hosts
  @tables [@vms, @hosts]
  @wait_timeout 10_000

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(_opts) do
    :ok = :net_kernel.monitor_nodes(true)
    :ok = join(Node.list())
    {:ok, %{}}
  end

  @impl true
  def handle_info({:nodeup, node}, state) do
    # A peer joined: (re-)merge our schema with the mesh and ensure a local copy
    # of every table. Idempotent for nodes we've already merged with.
    Logger.info("mnesia: node #{node} up — joining mesh store")
    _ = join(Node.list())
    {:noreply, state}
  end

  def handle_info({:nodedown, _node}, state), do: {:noreply, state}
  def handle_info(_msg, state), do: {:noreply, state}

  @doc """
  Join the local Mnesia store to `peers`, ensuring both tables exist and have a
  local `ram_copies` replica. Idempotent. With `peers == []` this is equivalent
  to creating the tables node-local (single-node / dev / non-distributed tests).
  """
  @spec join([node()]) :: :ok
  def join(peers) do
    :mnesia.start()

    if peers != [] do
      case :mnesia.change_config(:extra_db_nodes, peers) do
        {:ok, _merged} ->
          :ok

        {:error, reason} ->
          Logger.warning("mnesia: change_config(extra_db_nodes) failed: #{inspect(reason)}")
      end
    end

    # Serialize schema mutation across the whole mesh so exactly one node creates
    # each table; the rest add a local copy. :global.trans blocks under
    # contention rather than giving up.
    :global.trans(
      {{:brigade_mnesia_setup, :tables}, self()},
      fn -> ensure_tables() end,
      [node() | peers],
      :infinity
    )

    :ok = :mnesia.wait_for_tables(@tables, @wait_timeout)
    :ok
  end

  # Runs inside the global lock. For each table: create it if it exists nowhere
  # in the (merged) cluster, otherwise ensure this node holds a ram_copies copy.
  defp ensure_tables do
    existing = :mnesia.system_info(:tables)

    for {table, opts} <- table_specs() do
      if table in existing do
        ensure_local_copy(table)
      else
        create_table(table, opts)
      end
    end

    :ok
  end

  defp ensure_local_copy(table) do
    unless node() in :mnesia.table_info(table, :ram_copies) do
      case :mnesia.add_table_copy(table, node(), :ram_copies) do
        {:atomic, :ok} -> :ok
        {:aborted, {:already_exists, ^table, _node}} -> :ok
        {:aborted, reason} -> raise "mnesia add_table_copy #{table} failed: #{inspect(reason)}"
      end
    end
  end

  defp create_table(name, opts) do
    case :mnesia.create_table(name, opts) do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, ^name}} -> ensure_local_copy(name)
      {:aborted, reason} -> raise "mnesia create_table #{name} failed: #{inspect(reason)}"
    end
  end

  defp table_specs do
    [
      {@vms,
       [
         attributes: [:uid, :namespace, :host_id, :record],
         index: [:namespace, :host_id],
         ram_copies: [node()]
       ]},
      {@hosts, [attributes: [:id, :record], ram_copies: [node()]]}
    ]
  end
end
