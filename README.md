# Brigade

A distributed orchestrator for [flintlock](https://github.com/liquidmetal-dev/flintlock)
microVMs. Brigade speaks flintlock's exact gRPC `MicroVM` interface (drop-in), decides
which cluster member should run each microVM, and forwards the request to that host's
local `flintlockd`.

flintlock is a single-host agent — one `flintlockd` per bare-metal node, with no
scheduling, host selection, or cross-host awareness. Brigade fills that gap: clients
talk to Brigade as if it were a flintlock, and Brigade schedules across the fleet.

## Topology

Day 1 (**topology A**): a Brigade node runs on **every** flintlock host, meshed via
distributed Erlang (libcluster). Host liveness = Erlang node liveness; scheduling and
state ride the mesh with no external dependencies. Each Brigade node calls its local
`flintlockd` over `localhost:9090`.

```
client --(flintlock gRPC)--> any Brigade node
                                  |  singleton scheduler picks a host
                                  v
                             Brigade@hostC --localhost:9090--> flintlockd (hostC)
```

Everything host-facing is behind a behaviour (`Store`, `HostDriver`, `Scheduler.Strategy`,
`HostRegistry`) so a future **topology B** (central control plane dialing remote hosts)
can be added without touching the core.

## How it works

- **Drop-in gRPC** — Brigade implements flintlock's `MicroVM` service verbatim (protos
  vendored + pinned under `proto/`, gRPC-only; the gateway is not run). `uid` is
  pass-through: flintlock assigns it, Brigade stores `uid -> host`.
- **Singleton scheduler** — a Horde-managed cluster singleton serializes placement, so
  concurrent creates can never overcommit a host. Capacity = declared total − OS reserve
  − committed (from the store) − in-flight (in memory). Placement is filter → score
  (least-loaded spread by default).
- **State** — Mnesia (`ram_copies`), the source of truth for placement and for answering
  `ListMicroVMs`.
- **Failure handling** — dual-liveness (Erlang `nodedown` + a TCP health probe of the
  local flintlock); a dead node's hosts go `unreachable` and their capacity is released
  (no auto-reschedule); a per-host reconciler (~30s, state-sync only) adopts orphans,
  marks lost VMs, and resolves ambiguous creates. Placement is **quorum-gated**: a
  minority partition refuses new placements (split-brain guard) while reads stay
  available.
- **Auth** — mirrors flintlock's basic-auth token on both edges (north: clients →
  Brigade; south: Brigade → flintlock), with optional mTLS south.
- **Observability** — `:telemetry` events + a Prometheus `/metrics` endpoint, plus a
  JSON `/status` and `/healthz`.

## Requirements

- Elixir 1.18 / OTP 27 (managed via [mise](https://mise.jdx.dev): `mise install`).
- A running `flintlockd` on each host (`localhost:9090`) for real use. Tests use an
  in-memory fake, so no hardware is required.

## Run

```sh
mise exec -- mix deps.get
mise exec -- mix run --no-halt        # boots the app with config/config.exs
```

Endpoints (defaults):

| Port | What |
|------|------|
| 9091 | Brigade gRPC (north edge — point flintlock clients here) |
| 9600 | `GET /status` (JSON cluster view), `GET /healthz` |
| 9568 | `GET /metrics` (Prometheus) |

## Configuration

All settings live under `config :brigade` (see `config/config.exs`). Key ones:

| Key | Default | Meaning |
|-----|---------|---------|
| `grpc_port` | `9091` | north-edge gRPC listen port |
| `flintlock_endpoint` | `localhost:9090` | local flintlockd (south edge) |
| `host` | 8 vcpu / 16 GB, 1 vcpu / 2 GB reserve | this host's declared capacity, labels, providers |
| `scheduler_strategy` | `LeastLoaded` | placement strategy |
| `min_cluster_size` | `1` | quorum for placement (set to majority in real clusters) |
| `auth_token` | `nil` | north-edge basic-auth token (nil = disabled) |
| `flintlock_auth_token` / `flintlock_tls` | `nil` | south-edge auth / mTLS |
| `cluster_topologies` | `[]` | libcluster config (e.g. Gossip for bare-metal LAN) |
| `reconcile_interval_ms` | `30_000` | per-host reconcile cadence |

Labels prefixed `brigade.scheduling/` on a `MicroVMSpec` become placement constraints
(matched against host labels); all labels are still passed through to flintlock.

## Releases

Pushing a semver tag runs `.github/workflows/release.yml`, which publishes two
artifacts (version taken from the tag, `v` stripped):

```sh
git tag v1.2.3 && git push origin v1.2.3   # -rc/-beta suffixes → prerelease
```

- **OTP tarball** — `mix release` output attached to the GitHub Release. Bundles ERTS,
  built on `ubuntu-latest` (glibc, linux/amd64); the target host must match that
  OS/arch. Unpack and run `bin/brigade start`.
- **Container image** — pushed to `ghcr.io/liquidmetal-dev/brigade:1.2.3` (plus
  `:1.2` and, for stable tags, `:latest`):

  ```sh
  docker run --rm ghcr.io/liquidmetal-dev/brigade:1.2.3 version
  ```

Prod settings are read from the environment at boot via `config/runtime.exs`
(`BRIGADE_GRPC_PORT`, `BRIGADE_AUTH_TOKEN`, `FLINTLOCK_ENDPOINT`, …); unset vars fall
back to the `config/config.exs` defaults above.

## Testing

```sh
mise exec -- mix test                          # hermetic suite (fake flintlock, no hardware)
mise exec -- mix test --include distributed    # + real multi-node peer tests
```

The fake flintlock (`test/support/fake_flintlock.ex`) is an in-memory gRPC `MicroVM`
server used as the drop-in conformance oracle. The overcommit property test hammers
concurrent creates and asserts no host is ever overcommitted; the distributed tests form
a real Erlang mesh and assert exactly one scheduler + failover.

## Status

Milestones M0–M4 complete: contract + scaffold, single-node happy path, cluster +
singleton scheduler, failure handling, and hardening (auth, observability, docs).

Not yet implemented (deferred): topology B (remote hosts), auto-reschedule of cattle
VMs, bin-pack strategy, grpc-gateway HTTP/JSON, live migration, distributed tracing.
