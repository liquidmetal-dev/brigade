import Config

config :brigade,
  # seams (swappable for topology B)
  store: Brigade.Store.Mnesia,
  host_driver: Brigade.HostDriver.Local,
  scheduler_strategy: Brigade.Scheduler.Strategy.LeastLoaded,
  # Split-brain guard: scheduler places only when its partition has >= this many
  # nodes. 1 = no gating (single-node/dev). Set to majority for real clusters.
  min_cluster_size: 1,
  # Guardian re-checks that the singleton scheduler is alive this often (and on
  # every mesh membership change), resurrecting it on a survivor after failover.
  scheduler_guardian_interval_ms: 3_000,
  # north edge: Brigade's own gRPC listen port (distinct from flintlock's 9090)
  start_server: true,
  grpc_port: 9091,
  # north edge: require this basic-auth token from clients (nil = auth disabled).
  auth_token: nil,
  # south edge: local flintlockd (topology A)
  flintlock_endpoint: "localhost:9090",
  # south-edge auth to flintlock (nil on loopback; set for topology B).
  flintlock_auth_token: nil,
  # nil = plaintext; %{cacertfile:, certfile:, keyfile:} = mTLS to flintlock.
  flintlock_tls: nil,
  # flintlock gRPC API contract this build implements (pin in proto/README.md).
  # Kept in sync by `mix proto.bump`; surfaced on GET /status.
  flintlock_api_version: "v0.11.0",
  self_register: true,
  # Local flintlock liveness + drift reconcile (topology A).
  local_flintlock: true,
  health_interval_ms: 5_000,
  reconcile_interval_ms: 30_000,
  probe_namespace: "brigade-health",
  reconcile_namespaces: [],
  # libcluster topologies for mesh formation. Empty = no auto-clustering (single
  # node / dev). For bare-metal LAN, Gossip auto-forms with no central registry:
  #   cluster_topologies: [
  #     brigade: [strategy: Cluster.Strategy.Gossip]
  #   ]
  # Epmd/DNS strategies work too — see libcluster docs.
  cluster_topologies: [],
  # Observability.
  metrics_enabled: true,
  metrics_port: 9568,
  metrics_poll_ms: 10_000,
  status_enabled: true,
  status_port: 9600,
  # this host's declared capacity + labels (see plan Q5/Q16)
  host: [
    labels: %{},
    capacity: [vcpu: 8, memory_mb: 16_384],
    reserve: [vcpu: 1, memory_mb: 2_048],
    providers: []
  ]

import_config "#{config_env()}.exs"
