defmodule Brigade.LocalFlintlock do
  @moduledoc """
  Supervises the co-located flintlock's liveness + drift correction: a
  `HealthMonitor` (dual-liveness) and a `Reconciler` (periodic state-sync).

  Both operate on the *local* host — the store record whose `node` is this node —
  so they scale naturally (each node minds its own flintlock over localhost) and
  stay partition-local.
  """
  use Supervisor

  def start_link(opts), do: Supervisor.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(opts) do
    children = [
      {Brigade.LocalFlintlock.HealthMonitor, opts},
      {Brigade.LocalFlintlock.Reconciler, opts}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc "The store record for this node's local host, if registered."
  def local_host do
    case store().list_hosts() do
      {:ok, hosts} ->
        case Enum.find(hosts, &(&1.node == Node.self())) do
          nil -> :error
          host -> {:ok, host}
        end

      _ ->
        :error
    end
  end

  def driver, do: Application.get_env(:brigade, :host_driver, Brigade.HostDriver.Local)
  def store, do: Application.get_env(:brigade, :store, Brigade.Store.Mnesia)
end
