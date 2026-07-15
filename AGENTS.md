# AGENTS.md

Working rules for AI coding agents in this repo. Keep changes small, run the checks
below before proposing a commit.

## What Brigade is

A distributed Elixir/OTP orchestrator for [flintlock](https://github.com/liquidmetal-dev/flintlock)
microVMs: a drop-in gRPC `MicroVM` server that schedules each VM onto a cluster member
and forwards to that host's local `flintlockd`. See `README.md` for the full
architecture (topology A, singleton scheduler, dual-liveness, quorum gating).

## Toolchain

Elixir 1.18.4 / OTP 27, pinned in `mise.toml` (`[tools]`). **Always run mix through
mise** — never call bare `mix`:

```sh
mise exec -- mix deps.get
mise exec -- mix compile --warnings-as-errors
mise exec -- mix format                       # run before every commit
mise exec -- mix format --check-formatted     # CI gate
mise exec -- mix test                         # hermetic (fake flintlock, no hardware)
# Distributed peer-node tests need a distributed VM (named node + cookie) —
# plain `mix test --include distributed` fails with :nodistribution:
mise exec -- elixir --name dev@127.0.0.1 --cookie brigade_test -S mix test --include distributed
mise exec -- mix protobuf.generate            # proto codegen only (dev dep)
mise exec -- mix proto.bump v0.9.2            # bump pinned flintlock protos (download+strip+regen)
```

## Layout

```
lib/brigade/
  application.ex        # OTP boot order (store → cluster → registry → flintlock → telemetry → status → gRPC)
  scheduler.ex          # placement; scheduler/strategy/least_loaded.ex is the default
  grpc/                 # server.ex, endpoint.ex, auth interceptor; proto/ = generated stubs
  host_driver/local.ex  # south-edge: dials local flintlockd
  host_registry.ex      # Horde-backed host inventory + self-register
  local_flintlock.ex    # dual-liveness health probe + drift reconciler
  store.ex              # Mnesia (ram_copies) placement state
  telemetry.ex          # :telemetry events + Prometheus exporter
  status.ex             # /status + /healthz HTTP (Bandit)
config/                 # config.exs (base) + {dev,test,prod}.exs
test/                   # hermetic suite; support/fake_flintlock.ex is the oracle
proto/                  # vendored + pinned flintlock protos (v0.9.1)
```

## Conventions

- **Behaviour seams** — `Store`, `HostDriver`, `Scheduler.Strategy`, `HostRegistry`
  are behaviours so a future topology B (central control plane dialing remote hosts)
  drops in without touching the core. Prefer implementing a new module behind a seam
  over editing the core.
- **Protos are generated** — never hand-edit `lib/brigade/grpc/proto/`. Change the
  vendored `.proto` under `proto/` (pinned to flintlock v0.9.1), then
  `mise exec -- mix protobuf.generate`.
- **Config** — all settings live under `config :brigade` in `config/config.exs`.
  Tests build their own supervised components per-case, so `config/test.exs` disables
  auto-start (`start_server`, `self_register`, `local_flintlock`, metrics, status).
- **Style** — `mix format` is authoritative (`.formatter.exs`). Code must compile
  clean with `--warnings-as-errors`.

## Testing rules

- The fake flintlock (`test/support/fake_flintlock.ex`) is the drop-in conformance
  oracle — hermetic, no hardware.
- The scheduler overcommit property test must stay green: it hammers concurrent
  creates and asserts no host is ever overcommitted.
- Distributed tests (`--include distributed`) spin real Erlang peer nodes and assert
  exactly one scheduler + failover; excluded by default (`test/test_helper.exs`).

## Before you commit

1. `mise exec -- mix format`
2. `mise exec -- mix compile --warnings-as-errors`
3. `mise exec -- mix test`

Do **not** add a `Co-Authored-By` trailer to commits in this project.
