defmodule Brigade.GRPC.Endpoint do
  @moduledoc "North-edge gRPC endpoint exposing Brigade's drop-in MicroVM service."
  use GRPC.Endpoint

  intercept(Brigade.GRPC.AuthInterceptor, token_key: :auth_token)
  run(Brigade.GRPC.Server)
end
