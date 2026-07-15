defmodule Brigade.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    scheduler_opts = [strategy: Application.get_env(:brigade, :scheduler_strategy)]

    # Horde registry + dynamic supervisor + singleton scheduler starter.
    children =
      [
        # gRPC client connection pool — HostDriver dials each host's flintlockd
        # through this (south edge). Required by grpc >= 0.11.
        {GRPC.Client.Supervisor, []},
        # Mnesia tables must exist before anything reads/writes state.
        Brigade.Store.Mnesia.Setup
      ] ++
        maybe_libcluster() ++
        Brigade.Cluster.child_specs(scheduler_opts) ++
        maybe_self_register() ++
        maybe_server()

    # M3+: LocalFlintlock health + reconciler, dual-liveness, quorum gate. Telemetry (M4).

    opts = [strategy: :one_for_one, name: Brigade.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp maybe_libcluster do
    case Application.get_env(:brigade, :cluster_topologies, []) do
      [] ->
        []

      topologies ->
        [{Cluster.Supervisor, [topologies, [name: Brigade.ClusterSupervisor]]}]
    end
  end

  defp maybe_self_register do
    if Application.get_env(:brigade, :self_register, true),
      do: [Brigade.HostRegistry.SelfRegister],
      else: []
  end

  defp maybe_server do
    if Application.get_env(:brigade, :start_server, true) do
      port = Application.get_env(:brigade, :grpc_port, 9091)
      [{GRPC.Server.Supervisor, endpoint: Brigade.GRPC.Endpoint, port: port, start_server: true}]
    else
      []
    end
  end
end
