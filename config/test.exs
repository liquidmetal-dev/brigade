import Config

# Tests build their own supervised components (store setup, scheduler, endpoint,
# host registration) per-case for isolation, so the application should not
# auto-start the north endpoint or self-register a host.
config :brigade,
  start_server: false,
  self_register: false,
  # Tests drive the health monitor / reconciler explicitly via check_now/reconcile_now.
  local_flintlock: false,
  # Tests exercise telemetry/status directly; don't bind ports at app boot.
  metrics_enabled: false,
  status_enabled: false
