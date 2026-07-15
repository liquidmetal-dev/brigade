import Config

config :brigade,
  # seams (swappable for topology B)
  store: Brigade.Store.Mnesia,
  host_driver: Brigade.HostDriver.Local,
  scheduler_strategy: Brigade.Scheduler.Strategy.LeastLoaded,
  # north edge: Brigade's own gRPC listen port (distinct from flintlock's 9090)
  start_server: true,
  grpc_port: 9091,
  # south edge: local flintlockd (topology A)
  flintlock_endpoint: "localhost:9090",
  self_register: true,
  # libcluster topologies for mesh formation. Empty = no auto-clustering (single
  # node / dev). For bare-metal LAN, Gossip auto-forms with no central registry:
  #   cluster_topologies: [
  #     brigade: [strategy: Cluster.Strategy.Gossip]
  #   ]
  # Epmd/DNS strategies work too — see libcluster docs.
  cluster_topologies: [],
  # this host's declared capacity + labels (see plan Q5/Q16)
  host: [
    labels: %{},
    capacity: [vcpu: 8, memory_mb: 16_384],
    reserve: [vcpu: 1, memory_mb: 2_048],
    providers: []
  ]

import_config "#{config_env()}.exs"
