defmodule Brigade.GRPC.AuthInterceptor do
  @moduledoc """
  North-edge auth, mirroring flintlock's basic-auth token. When configured, every
  RPC must carry `authorization: Bearer <token>`; otherwise the call is rejected
  `unauthenticated`. When the token is unset (default), auth is disabled — the
  permissive local-dev posture.

  The token is read from `Application.get_env(:brigade, token_key)`, where
  `token_key` is supplied at `intercept` time. This lets independent endpoints
  (Brigade's north edge, and the test fake flintlock) each gate on their own
  token without sharing global state.
  """
  @behaviour GRPC.Server.Interceptor

  @impl true
  def init(opts), do: Keyword.get(opts, :token_key, :auth_token)

  @impl true
  def call(req, stream, next, token_key) do
    case Application.get_env(:brigade, token_key) do
      nil ->
        next.(req, stream)

      token ->
        if authorized?(GRPC.Stream.get_headers(stream), token) do
          next.(req, stream)
        else
          raise GRPC.RPCError, status: :unauthenticated, message: "invalid or missing auth token"
        end
    end
  end

  defp authorized?(headers, token) do
    case headers["authorization"] do
      "Bearer " <> presented -> secure_equal?(presented, token)
      _ -> false
    end
  end

  # Constant-time comparison to avoid leaking the token via timing.
  defp secure_equal?(a, b) when byte_size(a) == byte_size(b) do
    :crypto.exor(a, b) |> :binary.bin_to_list() |> Enum.reduce(0, &Bitwise.bor/2) == 0
  end

  defp secure_equal?(_, _), do: false
end
