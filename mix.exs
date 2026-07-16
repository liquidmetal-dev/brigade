defmodule Brigade.MixProject do
  use Mix.Project

  def project do
    [
      app: :brigade,
      # Version is normally driven by the pushed git tag in CI
      # (BRIGADE_VERSION, set by .github/workflows/release.yml). The literal
      # is the local/dev fallback.
      version: System.get_env("BRIGADE_VERSION") || "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      releases: releases(),
      deps: deps()
    ]
  end

  # `mix release` config. The :tar step emits a self-contained
  # _build/prod/brigade-<version>.tar.gz (bundles ERTS) for GitHub Releases;
  # the Dockerfile uses the assembled release for the GHCR image.
  defp releases do
    [
      brigade: [
        include_executables_for: [:unix],
        steps: [:assemble, :tar]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # :os_mon powers the capacity probe guardrail (cpu_sup / memsup).
      extra_applications: [:logger, :os_mon, :mnesia],
      mod: {Brigade.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # gRPC server (north edge) + client (south edge, calls flintlock).
      {:grpc, "~> 0.10"},
      # protobuf >= 0.14 bundles the Google.Protobuf.* well-known types
      # (Empty, Timestamp, Struct, …), so no separate google_protos dep — it
      # would ship duplicate modules and fail `mix release` assembly.
      {:protobuf, "~> 0.14"},
      # Distributed Erlang: mesh formation + cluster-singleton scheduler.
      {:libcluster, "~> 3.5"},
      {:horde, "~> 0.9"},
      # Observability: telemetry events + prometheus scrape endpoint.
      {:telemetry, "~> 1.2"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_metrics_prometheus, "~> 1.1"},
      # Status HTTP endpoint.
      {:plug, "~> 1.16"},
      {:bandit, "~> 1.5"},
      {:jason, "~> 1.4"},
      # protoc-gen-elixir wrapper — `mix protobuf.generate` (codegen only).
      {:protobuf_generate, "~> 0.1", only: :dev, runtime: false}
    ]
  end
end
