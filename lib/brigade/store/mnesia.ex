defmodule Brigade.Store.Mnesia do
  @moduledoc """
  Mnesia implementation of `Brigade.Store`.

  Day-1 tables are `ram_copies` (in-memory) — disc persistence is an M4
  hardening add. Replication across the mesh is **not** automatic: it is
  established explicitly at join time by `Brigade.Store.Mnesia.Cluster` (schema
  merge + a local `ram_copies` copy on every node). Two tables:

    * `:brigade_vms`   — key `uid`, indexed on `namespace` and `host_id`, value
      is the full `Brigade.VMRecord` struct.
    * `:brigade_hosts` — key `id`, value is the full `Brigade.Host` struct.

  Capacity/reservations are NOT a separate table: a host's committed allocation
  is the sum of vcpu/memory over its VM records in schedulable states, computed
  by the scheduler via `list_vms_on_host/1`.
  """
  @behaviour Brigade.Store

  alias Brigade.{Host, VMRecord}

  @vms :brigade_vms
  @hosts :brigade_hosts

  # --- setup ----------------------------------------------------------------

  @doc """
  Ensure the tables exist and are joined to the mesh. Thin wrapper over
  `Brigade.Store.Mnesia.Cluster.join/1` — kept for the "tables exist after this
  returns" contract. `Brigade.Store.Mnesia.Cluster` is the supervised worker.
  """
  def setup!, do: Brigade.Store.Mnesia.Cluster.join(Node.list())

  # --- VM records -----------------------------------------------------------

  @impl true
  def put_vm(%VMRecord{} = vm) do
    write(fn -> :mnesia.write({@vms, vm.uid, vm.namespace, vm.host_id, vm}) end)
  end

  @impl true
  def get_vm(uid) do
    read(fn ->
      case :mnesia.read(@vms, uid) do
        [{@vms, ^uid, _ns, _host, rec}] -> {:ok, rec}
        [] -> {:error, :not_found}
      end
    end)
  end

  @impl true
  def delete_vm(uid) do
    write(fn -> :mnesia.delete({@vms, uid}) end)
  end

  @impl true
  def list_vms(namespace, name \\ nil) do
    read(fn ->
      @vms
      |> :mnesia.index_read(namespace, :namespace)
      |> Enum.map(fn {@vms, _uid, _ns, _host, rec} -> rec end)
      |> filter_name(name)
      |> then(&{:ok, &1})
    end)
  end

  @impl true
  def list_vms_on_host(host_id) do
    read(fn ->
      @vms
      |> :mnesia.index_read(host_id, :host_id)
      |> Enum.map(fn {@vms, _uid, _ns, _host, rec} -> rec end)
      |> then(&{:ok, &1})
    end)
  end

  defp filter_name(vms, nil), do: vms
  defp filter_name(vms, ""), do: vms
  defp filter_name(vms, name), do: Enum.filter(vms, &(&1.name == name))

  # --- Host inventory -------------------------------------------------------

  @impl true
  def put_host(%Host{} = host) do
    write(fn -> :mnesia.write({@hosts, host.id, host}) end)
  end

  @impl true
  def get_host(host_id) do
    read(fn ->
      case :mnesia.read(@hosts, host_id) do
        [{@hosts, ^host_id, rec}] -> {:ok, rec}
        [] -> {:error, :not_found}
      end
    end)
  end

  @impl true
  def list_hosts do
    read(fn ->
      rows = :mnesia.foldl(fn {@hosts, _id, rec}, acc -> [rec | acc] end, [], @hosts)
      {:ok, rows}
    end)
  end

  # --- transaction helpers --------------------------------------------------

  defp write(fun) do
    case :mnesia.transaction(fun) do
      {:atomic, _} -> :ok
      {:aborted, reason} -> {:error, reason}
    end
  end

  defp read(fun) do
    case :mnesia.transaction(fun) do
      {:atomic, result} -> result
      {:aborted, reason} -> {:error, reason}
    end
  end
end
