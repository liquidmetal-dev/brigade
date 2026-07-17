defmodule Brigade.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    scheduler_opts = [
      strategy: Application.get_env(:brigade, :scheduler_strategy),
      min_cluster_size: Application.get_env(:brigade, :min_cluster_size, 1)
    ]

    # Horde registry + dynamic supervisor + singleton scheduler starter.
    # libcluster first so peers are connected when the store joins the mesh;
    # the store's nodeup handler is the backstop for async/late joins.
    # Mnesia tables must exist (and be mesh-joined) before anything
    # reads/writes state or the scheduler starts.
    children =
      [
        # gRPC client connection pool — HostDriver dials each host's flintlockd
        # through this (south edge). Required by grpc >= 0.11.
        {GRPC.Client.Supervisor, []}
      ] ++
        maybe_libcluster() ++
        [Brigade.Store.Mnesia.Cluster] ++
        Brigade.Cluster.child_specs(scheduler_opts) ++
        maybe_self_register() ++
        maybe_local_flintlock() ++
        maybe_telemetry() ++
        maybe_status_endpoint() ++
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

  defp maybe_telemetry do
    if Application.get_env(:brigade, :metrics_enabled, true),
      do: Brigade.Telemetry.child_specs(),
      else: []
  end

  defp maybe_status_endpoint do
    if Application.get_env(:brigade, :status_enabled, true) do
      port = Application.get_env(:brigade, :status_port, 9600)
      [{Bandit, plug: Brigade.Status.Router, port: port}]
    else
      []
    end
  end

  defp maybe_local_flintlock do
    if Application.get_env(:brigade, :local_flintlock, true),
      do: [Brigade.LocalFlintlock],
      else: []
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
