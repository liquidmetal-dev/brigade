defmodule Brigade.HostDriver.Local do
  @moduledoc """
  Day-1 (topology A) `Brigade.HostDriver`: dials the co-located `flintlockd` over
  the host's endpoint (localhost:9090 by default) using the generated gRPC stub.

  No auth/TLS on the loopback hop day 1; the token/mTLS path lands with the
  `Remote` driver for topology B.
  """
  @behaviour Brigade.HostDriver

  alias Microvm.Services.Api.V1alpha1.MicroVM.Stub
  alias Microvm.Services.Api.V1alpha1, as: Api

  @impl true
  def connect(%Brigade.Host{endpoint: endpoint}) do
    GRPC.Stub.connect(endpoint)
  end

  @impl true
  def create(channel, %Api.CreateMicroVMRequest{} = req) do
    Stub.create_micro_vm(channel, req)
  end

  @impl true
  def get(channel, uid) do
    Stub.get_micro_vm(channel, %Api.GetMicroVMRequest{uid: uid})
  end

  @impl true
  def delete(channel, uid) do
    case Stub.delete_micro_vm(channel, %Api.DeleteMicroVMRequest{uid: uid}) do
      {:ok, %Google.Protobuf.Empty{}} -> :ok
      other -> other
    end
  end

  @impl true
  def list(channel, namespace) do
    Stub.list_micro_v_ms(channel, %Api.ListMicroVMsRequest{namespace: namespace})
  end
end
