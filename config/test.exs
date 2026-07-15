import Config

# Tests build their own supervised components (store setup, scheduler, endpoint,
# host registration) per-case for isolation, so the application should not
# auto-start the north endpoint or self-register a host.
config :brigade,
  start_server: false,
  self_register: false
