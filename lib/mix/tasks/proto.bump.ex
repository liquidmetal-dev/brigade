defmodule Mix.Tasks.Proto.Bump do
  @shortdoc "Bump the pinned flintlock proto version (download + strip + regenerate)"

  @moduledoc """
  Update the vendored/pinned flintlock protos to a new upstream tag.

  Downloads the pristine `microvms.proto` and `types/microvm.proto` from the
  flintlock repo at the given git ref into `proto/vendor/`, re-derives the
  codegen inputs under `proto/` (re-applying the grpc-gateway strip to
  `microvms.proto`; `types/microvm.proto` is copied verbatim), then regenerates
  the Elixir stubs under `lib/brigade/grpc/proto/` and runs `mix format`.

  This is the one-command version of the manual "Bumping the pin" checklist in
  `proto/README.md`.

      mise exec -- mix proto.bump v0.9.2

  ## Arguments

    * `ref` — flintlock git ref to pin (tag/branch/sha), e.g. `v0.9.2`.

  ## Options

    * `--no-generate` — download + strip only; skip stub codegen and format.
      Useful to eyeball the vendor diff before committing to regen.
    * `--repo` — override source repo (default `liquidmetal-dev/flintlock`).

  After running: diff `proto/vendor/` against the previous pin, then run the
  fake-flintlock conformance tests (`mise exec -- mix test`).
  """
  use Mix.Task

  @default_repo "liquidmetal-dev/flintlock"

  # Upstream paths (relative to the flintlock repo root) → local vendor paths.
  @files [
    {"api/services/microvm/v1alpha1/microvms.proto",
     "proto/vendor/services/microvm/v1alpha1/microvms.proto"},
    {"api/types/microvm.proto", "proto/vendor/types/microvm.proto"}
  ]

  # Imports that only exist to support the grpc-gateway REST/openapiv2 layer.
  # Brigade is gRPC-only, so they are dropped from the codegen input.
  @gateway_imports [
    "google/protobuf/field_mask.proto",
    "google/api/annotations.proto",
    "protoc-gen-openapiv2/options/annotations.proto"
  ]

  @impl Mix.Task
  def run(argv) do
    {opts, args} =
      OptionParser.parse!(argv,
        strict: [generate: :boolean, repo: :string],
        aliases: []
      )

    ref =
      case args do
        [ref] ->
          ref

        _ ->
          Mix.raise("usage: mix proto.bump <ref>   (e.g. mix proto.bump v0.9.2)")
      end

    repo = opts[:repo] || @default_repo
    generate? = Keyword.get(opts, :generate, true)

    Mix.shell().info("Bumping flintlock protos to #{repo}@#{ref}")

    start_http!()

    for {upstream, vendor} <- @files do
      url = "https://raw.githubusercontent.com/#{repo}/#{ref}/#{upstream}"
      Mix.shell().info("  fetch #{url}")
      body = fetch!(url)
      write!(vendor, body)
    end

    # Re-derive codegen inputs from the freshly vendored pristine copies.
    File.cp!(
      "proto/vendor/types/microvm.proto",
      "proto/types/microvm.proto"
    )

    vendored_service = File.read!("proto/vendor/services/microvm/v1alpha1/microvms.proto")

    write!(
      "proto/services/microvm/v1alpha1/microvms.proto",
      strip_gateway(vendored_service, repo, ref)
    )

    update_readme_pin(ref)
    update_config_pin(ref)

    if generate? do
      Mix.shell().info("  regenerating stubs")
      regenerate!()
    else
      Mix.shell().info("  --no-generate: skipping stub codegen")
    end

    Mix.shell().info("""

    Done. Next:
      1. git diff proto/vendor/   # review upstream changes vs previous pin
      2. mise exec -- mix test    # fake-flintlock conformance suite
    """)
  end

  # --- gateway strip -------------------------------------------------------
  #
  # Mirrors the hand-edit documented in proto/README.md: strip everything that
  # only feeds the HTTP/JSON gateway (openapiv2 swagger option, per-rpc
  # google.api.http options, and their now-unused imports). Wire format is
  # untouched, so generated stubs stay byte-for-byte the upstream contract.
  defp strip_gateway(content, repo, ref) do
    content
    |> drop_gateway_imports()
    |> drop_swagger_option()
    |> collapse_rpc_options()
    |> prepend_header(repo, ref)
  end

  defp drop_gateway_imports(content) do
    Enum.reduce(@gateway_imports, content, fn imp, acc ->
      String.replace(acc, ~r/^import "#{Regex.escape(imp)}";\n/m, "")
    end)
  end

  # Remove the top-level `option (...openapiv2_swagger) = { ... };` block.
  # Non-greedy up to the first line-anchored `};` (inner braces are `  }`, no
  # semicolon, so they don't match).
  defp drop_swagger_option(content) do
    String.replace(
      content,
      ~r/\noption \(grpc\.gateway\.protoc_gen_openapiv2\.options\.openapiv2_swagger\) = \{.*?\n\};\n/s,
      ""
    )
  end

  # `rpc Foo(Req) returns (Resp) { option (google.api.http) = {...}; }`
  #   -> `rpc Foo(Req) returns (Resp);`
  # Streaming rpcs already end in `;` and have no block, so they're untouched.
  defp collapse_rpc_options(content) do
    String.replace(
      content,
      ~r/(rpc [^\n]*?\)) \{\n\s*option \(google\.api\.http\).*?\n  \}/s,
      "\\1;"
    )
  end

  defp prepend_header(content, repo, ref) do
    header = """
    // Brigade codegen input. Wire-identical to flintlock #{ref}
    // api/services/microvm/v1alpha1/microvms.proto (pristine copy under proto/vendor/).
    // The grpc-gateway REST/openapiv2 annotations (google.api.http, openapiv2_swagger)
    // have been removed: they affect ONLY the HTTP/JSON gateway, never the gRPC wire
    // format, and Brigade is gRPC-only day 1. Service/message/field definitions are
    // byte-for-byte the upstream contract, so generated stubs match flintlock exactly.
    """

    _ = repo
    String.replace(content, ~r/^package /m, header <> "package ", global: false)
  end

  # --- codegen -------------------------------------------------------------
  defp regenerate! do
    Mix.Task.run("protobuf.generate", [
      "--output-path=./lib/brigade/grpc/proto",
      "--include-path=./proto",
      "--generate-descriptors=true",
      "--plugin=ProtobufGenerate.Plugins.GRPC",
      "services/microvm/v1alpha1/microvms.proto",
      "types/microvm.proto"
    ])

    # Generated stubs are checked in formatted; keep the tree format-clean.
    Mix.Task.rerun("format", [
      "lib/brigade/grpc/proto/services/microvm/v1alpha1/microvms.pb.ex",
      "lib/brigade/grpc/proto/types/microvm.pb.ex"
    ])
  end

  # --- README pin ----------------------------------------------------------
  defp update_readme_pin(ref) do
    path = "proto/README.md"

    with {:ok, body} <- File.read(path) do
      updated =
        body
        |> String.replace(~r/Pinned to flintlock `v[^`]+`/, "Pinned to flintlock `#{ref}`")
        |> String.replace(~r/pinned to flintlock v[\d.]+/, "pinned to flintlock #{ref}")

      if updated != body do
        File.write!(path, updated)
        Mix.shell().info("  updated pin reference in #{path}")
      end
    end
  end

  # Keep the exposed flintlock_api_version (surfaced on GET /status) in lockstep
  # with the pin. Mirrors update_readme_pin/1.
  defp update_config_pin(ref) do
    path = "config/config.exs"

    with {:ok, body} <- File.read(path) do
      updated =
        String.replace(
          body,
          ~r/flintlock_api_version: "v[^"]+"/,
          ~s(flintlock_api_version: "#{ref}")
        )

      if updated != body do
        File.write!(path, updated)
        Mix.shell().info("  updated flintlock_api_version in #{path}")
      end
    end
  end

  # --- http ----------------------------------------------------------------
  defp start_http! do
    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)
    :ok
  end

  defp fetch!(url) do
    http_opts = [
      ssl: [
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ],
      timeout: 30_000
    ]

    case :httpc.request(:get, {String.to_charlist(url), []}, http_opts, body_format: :binary) do
      {:ok, {{_v, 200, _r}, _headers, body}} ->
        body

      {:ok, {{_v, status, _r}, _headers, _body}} ->
        Mix.raise("download failed (HTTP #{status}): #{url}")

      {:error, reason} ->
        Mix.raise("download failed (#{inspect(reason)}): #{url}")
    end
  end

  defp write!(path, contents) do
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, contents)
  end
end
