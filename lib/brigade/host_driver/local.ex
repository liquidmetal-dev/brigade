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
  def connect(%Brigade.Host{endpoint: endpoint} = host) do
    # Auth headers ride the channel, so every RPC on it carries the token; TLS
    # creds (if configured) secure the hop. Topology A over loopback is usually
    # tokenless/plaintext; both paths are wired for topology B (remote hosts).
    opts =
      []
      |> put_headers(host.auth_token)
      |> put_cred(host.tls)

    GRPC.Stub.connect(endpoint, opts)
  end

  defp put_headers(opts, nil), do: opts

  defp put_headers(opts, token),
    do: Keyword.put(opts, :headers, [{"authorization", "Bearer " <> token}])

  defp put_cred(opts, nil), do: opts

  defp put_cred(opts, %{} = tls) do
    ssl =
      tls
      |> Map.take([:cacertfile, :certfile, :keyfile])
      |> Enum.map(fn {k, v} -> {k, String.to_charlist(v)} end)

    Keyword.put(opts, :cred, GRPC.Credential.new(ssl: ssl))
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
