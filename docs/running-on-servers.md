# Running Brigade on servers

Operator runbook for standing Brigade up on real hosts. For architecture and
internals see the [README](../README.md).

> **Config today is compile-time.** Brigade reads all settings from `config/*.exs`
> at build time. `config/prod.exs` mentions `config/runtime.exs`, but that file is
> not present yet — there are **no environment variables wired**. To change settings
> you edit `config/prod.exs` (or add your own `config/runtime.exs`) and rebuild. Env-
> driven config and `mix release` packaging are planned but not done — see
> [Deferred](#deferred).

## Prerequisites

- [mise](https://mise.jdx.dev) — provides the pinned Elixir 1.18.4 / OTP 27 toolchain.
- A running `flintlockd` on **every** host, reachable at `localhost:9090` (topology A).
- Open ports between operators/clients and each Brigade node:

  | Port | Purpose |
  |------|---------|
  | 9091 | Brigade gRPC — north edge, point flintlock clients here |
  | 9090 | local `flintlockd` — south edge (loopback) |
  | 9600 | `GET /status` (JSON cluster view), `GET /healthz` |
  | 9568 | `GET /metrics` (Prometheus) |
  | 4369 + epmd range | distributed Erlang (clustering between Brigade nodes) |

## Install

```sh
mise install                 # installs Elixir/OTP per mise.toml
mise exec -- mix deps.get
```

## Topology A

Day 1, a Brigade node runs on **every** flintlock host, meshed via distributed
Erlang. Host liveness = Erlang node liveness; scheduling and state ride the mesh with
no external store. Each Brigade node calls its own local `flintlockd` over loopback.

```
client --(flintlock gRPC)--> any Brigade node
                                  |  singleton scheduler picks a host
                                  v
                             Brigade@hostC --localhost:9090--> flintlockd (hostC)
```

## Configure

Settings live under `config :brigade`. Keys an operator typically sets:

| Key | Default | Meaning |
|-----|---------|---------|
| `grpc_port` | `9091` | north-edge gRPC listen port |
| `flintlock_endpoint` | `"localhost:9090"` | local `flintlockd` (south edge) |
| `auth_token` | `nil` | north-edge basic-auth Bearer token (nil = disabled) |
| `flintlock_auth_token` | `nil` | south-edge auth token to flintlock |
| `flintlock_tls` | `nil` | south-edge mTLS: `%{cacertfile:, certfile:, keyfile:}` |
| `min_cluster_size` | `1` | placement quorum — set to partition majority in real clusters |
| `cluster_topologies` | `[]` | libcluster mesh config (see below) |
| `host` | 8 vcpu / 16 GB, 1 vcpu / 2 GB reserve | this host's declared `capacity`, `reserve`, `labels`, `providers` |

Example `config/prod.exs`:

```elixir
import Config

config :brigade,
  auth_token: "replace-with-a-real-secret",
  flintlock_endpoint: "localhost:9090",
  min_cluster_size: 2,
  cluster_topologies: [
    brigade: [strategy: Cluster.Strategy.Gossip]
  ],
  host: [
    labels: %{"zone" => "rack-1"},
    capacity: [vcpu: 32, memory_mb: 131_072],
    reserve: [vcpu: 2, memory_mb: 4_096],
    providers: []
  ]
```

## Clustering

- Enable `cluster_topologies`. For a bare-metal LAN, `Cluster.Strategy.Gossip`
  auto-forms the mesh with no central registry. Epmd/DNS strategies also work — see
  the [libcluster docs](https://hexdocs.pm/libcluster).
- Set `min_cluster_size` to the **majority** of your cluster (e.g. `3` in a 5-node
  cluster). A minority partition then refuses new placements (split-brain guard) while
  reads stay available.
- Distributed Erlang needs a **named node** and a **shared cookie** across all nodes
  (see [Run](#run)).

## Auth and TLS

- **North edge (clients → Brigade):** set `auth_token`. Clients send
  `authorization: Bearer <token>`; comparison is constant-time. `nil` disables auth.
- **South edge (Brigade → flintlock):** set `flintlock_auth_token` for basic-auth, and
  `flintlock_tls` for mTLS. TLS files are PEM paths:

  ```elixir
  config :brigade,
    flintlock_auth_token: "flintlock-secret",
    flintlock_tls: %{
      cacertfile: "/etc/brigade/ca.crt",
      certfile:   "/etc/brigade/client.crt",
      keyfile:    "/etc/brigade/client.key"
    }
  ```

  On loopback (topology A) auth/TLS are usually unset; wire them for remote hops.

## Run

Start each node named, with a cookie shared across the cluster:

```sh
mise exec -- elixir \
  --name brigade@<this-host-ip> \
  --cookie <shared-cluster-cookie> \
  -S mix run --no-halt
```

For a single-node / dev boot, `mise exec -- mix run --no-halt` is enough (no name/cookie).

Put this behind your init system (systemd unit, etc.) so it restarts on failure.

## Verify

```sh
curl http://localhost:9600/healthz        # 200 in quorum, 503 if not
curl http://localhost:9600/status | jq    # cluster members, partition, per-host capacity
curl http://localhost:9568/metrics        # Prometheus scrape
```

Expected boot logs include a host-registration line, e.g.
`registered host brigade@host1 (localhost:9090) cap=...`, and a scheduler-singleton
election line.

## Observability

- Scrape `:9568/metrics` with Prometheus. Key series: `brigade.schedule.placed.count`,
  `brigade.schedule.rejected.count` (by `reason`), `brigade.host.up`,
  `brigade.host.free_vcpu` / `free_memory_mb` / `vm_count`, `brigade.partition.size`,
  `brigade.partition.in_quorum`, `brigade.schedulable_hosts`.
- Use `:9600/healthz` as a Kubernetes/LB liveness probe — `200` when the node's
  partition has quorum, `503` otherwise.

## Deferred

Not built yet, plan accordingly:

- **`mix release` packaging** — there's no OTP release today; run via `mix run`.
- **`config/runtime.exs` / env-driven config** — settings are compile-time; rebuild to
  change them.
- **Topology B** (central control plane dialing remote hosts) and auto-reschedule of
  cattle VMs.
