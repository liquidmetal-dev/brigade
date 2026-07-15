defmodule Brigade.MixProject do
  use Mix.Project

  def project do
    [
      app: :brigade,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:protobuf, "~> 0.14"},
      {:google_protos, "~> 0.4"},
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
