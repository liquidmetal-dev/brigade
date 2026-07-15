# Vendored flintlock protos

**Pinned to flintlock `v0.9.1`** (identical to `main` at vendor time).
Source: https://github.com/liquidmetal-dev/flintlock

Brigade implements this gRPC contract verbatim so clients treat Brigade as a
drop-in `flintlockd` (they can't tell the difference on the wire).

## Layout

- `vendor/` — **pristine** upstream copies, untouched. The pin reference; diff
  against upstream on version bumps.
- `services/microvm/v1alpha1/microvms.proto`, `types/microvm.proto` — **codegen
  input**. `types/microvm.proto` is pristine. `microvms.proto` has the
  grpc-gateway REST/openapiv2 annotations removed (`google.api.http`,
  `openapiv2_swagger`) — these affect only the HTTP/JSON gateway, never the gRPC
  wire format, and Brigade is gRPC-only day 1. Every service/message/field is
  byte-for-byte upstream, so generated stubs match flintlock exactly.

## Regenerate stubs

```
mix protobuf.generate
```

Generated Elixir is checked into `lib/brigade/grpc/proto/` for reproducible
builds (no protoc needed at deploy).

## Bumping the pin

1. Re-fetch upstream `api/services/microvm/v1alpha1/microvms.proto` and
   `api/types/microvm.proto` at the new tag into `vendor/`.
2. `diff` against the codegen copies; re-apply the gateway strip to `microvms.proto`.
3. `mix protobuf.generate`; run the fake-flintlock conformance tests.

## Security note

`grpc` hex advisory **CVE-2026-48599** (auth bypass via path binding override)
lives in the HTTP *transcoding* / gateway path. Brigade does not run the gateway
(gRPC only), so the affected surface is not active.
