import Config

# Evaluated at release boot on the target host (and by `mix` in dev/test).
# Compile-time defaults live in config/config.exs; this file only overrides the
# runtime-tunable keys from the environment, and only in :prod so dev/test are
# untouched. Every override is opt-in — an unset env var leaves the config.exs
# default in place, so behaviour is unchanged unless you export something.
if config_env() == :prod do
  get_int = fn var, default ->
    case System.get_env(var) do
      nil -> default
      "" -> default
      val -> String.to_integer(val)
    end
  end

  get_bool = fn var, default ->
    case System.get_env(var) do
      nil -> default
      val -> val in ~w(1 true TRUE yes on)
    end
  end

  # north edge — Brigade's own gRPC server
  config :brigade,
    grpc_port: get_int.("BRIGADE_GRPC_PORT", 9091),
    auth_token: System.get_env("BRIGADE_AUTH_TOKEN"),
    start_server: get_bool.("BRIGADE_START_SERVER", true)

  # south edge — local flintlockd
  config :brigade,
    flintlock_endpoint: System.get_env("FLINTLOCK_ENDPOINT") || "localhost:9090",
    flintlock_auth_token: System.get_env("FLINTLOCK_AUTH_TOKEN")

  # split-brain guard for real clusters
  config :brigade, min_cluster_size: get_int.("BRIGADE_MIN_CLUSTER_SIZE", 1)

  # observability endpoints
  config :brigade,
    metrics_enabled: get_bool.("BRIGADE_METRICS_ENABLED", true),
    metrics_port: get_int.("BRIGADE_METRICS_PORT", 9568),
    status_enabled: get_bool.("BRIGADE_STATUS_ENABLED", true),
    status_port: get_int.("BRIGADE_STATUS_PORT", 9600)
end
