defmodule Brigade.Cluster do
  @moduledoc """
  Distributed-Erlang substrate for the singleton scheduler.

  Every node runs a `Horde.Registry` and `Horde.DynamicSupervisor` (both
  `members: :auto`, so they auto-mesh with the same-named processes on connected
  nodes — libcluster does the connecting). The scheduler is started once into the
  Horde supervisor; Horde's unique registry guarantees exactly one instance
  cluster-wide and re-homes it on node death.

  M2 scope: single-writer correctness + failover. Quorum-gated placement for
  netsplit (so a minority partition doesn't run a second scheduler) is M3.
  """

  @registry Brigade.Scheduler.Registry
  @supervisor Brigade.Scheduler.Supervisor
  @singleton_key :singleton

  @doc "Child specs for the Horde stack + the singleton guardian."
  def child_specs(scheduler_opts \\ []) do
    [
      {Horde.Registry, name: @registry, keys: :unique, members: :auto},
      {Horde.DynamicSupervisor, name: @supervisor, strategy: :one_for_one, members: :auto},
      {Brigade.Cluster.Starter, scheduler_opts}
    ]
  end

  @doc """
  Ensure the singleton scheduler is running under Horde (idempotent across nodes,
  self-repairing).

  If the registry already resolves to a live pid anywhere in the mesh there is
  nothing to do. Otherwise we start a fresh child under the Horde supervisor on
  this (in-quorum) node.

  The child-spec id is randomized on each start — the same trick Horde uses when
  it re-homes a process — so a stale/zombie spec left in the supervisor CRDT after
  a failed re-home can never block a restart with `:already_present`. Single-
  instance is guaranteed by the `:unique` `Horde.Registry` key, not the child id:
  if two nodes race a start, only one process registers `:singleton`; the loser
  gets `{:already_started, _}` at `start_link` and exits.
  """
  def ensure_scheduler(scheduler_opts) do
    case Horde.Registry.lookup(@registry, @singleton_key) do
      [{pid, _}] when is_pid(pid) -> :ok
      _ -> start_child(scheduler_opts)
    end
  end

  defp start_child(scheduler_opts) do
    spec = %{
      id: {Brigade.Scheduler, System.unique_integer([:positive])},
      start: {Brigade.Scheduler, :start_link, [scheduler_opts]},
      restart: :transient
    }

    case Horde.DynamicSupervisor.start_child(@supervisor, spec) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
      {:error, :already_present} -> :ok
      other -> other
    end
  end

  def supervisor, do: @supervisor
end

defmodule Brigade.Cluster.Starter do
  @moduledoc """
  Guardian for the singleton scheduler. Registers it into the Horde supervisor at
  boot, then keeps watch: on every mesh membership change (`:nodeup`/`:nodedown`)
  and on a steady-state timer it re-runs `ensure_scheduler/1`.

  This closes the gap where a node death races Horde's CRDT propagation and the
  singleton is dropped with nothing to re-home it — the guardian on any surviving
  in-quorum node resurrects it, so `Brigade.Status`'s `scheduler_node` is never
  `null` while a quorum exists. `ensure_scheduler/1` is idempotent, so racing
  guardians across nodes converge to one scheduler.
  """
  use GenServer
  require Logger

  @default_interval_ms 3_000

  def start_link(scheduler_opts),
    do: GenServer.start_link(__MODULE__, scheduler_opts, name: __MODULE__)

  @impl true
  def init(scheduler_opts) do
    # Watch the mesh so we can re-ensure the singleton the moment topology changes.
    :net_kernel.monitor_nodes(true)

    # Ensure the singleton is registered before app start completes, so callers
    # never race an unregistered via-tuple.
    ensure(scheduler_opts)
    schedule_tick()

    {:ok, scheduler_opts}
  end

  @impl true
  def handle_info({:nodeup, node}, scheduler_opts) do
    Logger.debug("node #{node} up — ensuring scheduler singleton")
    ensure(scheduler_opts)
    {:noreply, scheduler_opts}
  end

  @impl true
  def handle_info({:nodedown, node}, scheduler_opts) do
    Logger.warning("node #{node} down — ensuring scheduler singleton on a survivor")
    ensure(scheduler_opts)
    {:noreply, scheduler_opts}
  end

  @impl true
  def handle_info(:tick, scheduler_opts) do
    ensure(scheduler_opts)
    schedule_tick()
    {:noreply, scheduler_opts}
  end

  @impl true
  def handle_info(_msg, scheduler_opts), do: {:noreply, scheduler_opts}

  defp ensure(scheduler_opts) do
    case Brigade.Cluster.ensure_scheduler(scheduler_opts) do
      :ok -> :ok
      other -> Logger.warning("scheduler singleton ensure returned: #{inspect(other)}")
    end
  end

  defp schedule_tick do
    interval =
      Application.get_env(:brigade, :scheduler_guardian_interval_ms, @default_interval_ms)

    Process.send_after(self(), :tick, interval)
  end
end
