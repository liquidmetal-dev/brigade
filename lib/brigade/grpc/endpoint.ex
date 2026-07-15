defmodule Brigade.GRPC.Endpoint do
  @moduledoc "North-edge gRPC endpoint exposing Brigade's drop-in MicroVM service."
  use GRPC.Endpoint

  run(Brigade.GRPC.Server)
end
