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

  @doc "Child specs for the Horde stack + the singleton starter."
  def child_specs(scheduler_opts \\ []) do
    [
      {Horde.Registry, name: @registry, keys: :unique, members: :auto},
      {Horde.DynamicSupervisor, name: @supervisor, strategy: :one_for_one, members: :auto},
      {Brigade.Cluster.Starter, scheduler_opts}
    ]
  end

  @doc "Ensure the singleton scheduler is running under Horde (idempotent across nodes)."
  def ensure_scheduler(scheduler_opts) do
    spec = %{
      id: Brigade.Scheduler,
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
  One-shot worker that registers the singleton scheduler into the Horde
  supervisor at boot. Horde dedups across the mesh, so racing starters on
  multiple nodes converge to a single scheduler.
  """
  use GenServer
  require Logger

  def start_link(scheduler_opts),
    do: GenServer.start_link(__MODULE__, scheduler_opts, name: __MODULE__)

  @impl true
  def init(scheduler_opts) do
    # Ensure the singleton is registered before app start completes, so callers
    # never race an unregistered via-tuple. Horde dedups across the mesh.
    case Brigade.Cluster.ensure_scheduler(scheduler_opts) do
      :ok -> :ok
      other -> Logger.warning("scheduler singleton start returned: #{inspect(other)}")
    end

    {:ok, scheduler_opts}
  end
end
