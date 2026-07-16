defmodule FakeFlintlock do
  @moduledoc """
  In-memory stand-in for a real `flintlockd`, implementing the flintlock
  `MicroVM` gRPC service exactly (same generated stubs Brigade's `HostDriver`
  dials). It mints a uid on create and answers Get/Delete/List from an Agent —
  no firecracker, no hardware.

  This is the CI keystone and the drop-in **conformance oracle**: if Brigade
  forwards a request that a real flintlock would accept, the fake accepts it too.

  M0 scope: a single instance backed by one named Agent. Per-instance state
  (for multi-host M2 tests) is a later addition.
  """

  alias Microvm.Services.Api.V1alpha1, as: Api
  alias Flintlock.Types

  @store __MODULE__.Store

  # --- Lifecycle helpers (tests call these) ---------------------------------

  @doc "Supervised child spec for the in-memory store Agent."
  def store_child_spec do
    %{id: @store, start: {Agent, :start_link, [fn -> %{} end, [name: @store]]}}
  end

  @doc """
  Start the gRPC endpoint listening on `port`. Pair with `stop_endpoint/0`.

  Retries on `:eaddrinuse`: `stop_endpoint/0` returns before the OS actually
  releases the listen socket (Ranch closes it asynchronously), so a prior
  case's port can still be bound when the next `setup` re-binds the same fixed
  port. Bounded retry absorbs that race instead of failing the setup.
  """
  def start_endpoint(port, retries \\ 20) do
    case GRPC.Server.start_endpoint(FakeFlintlock.Endpoint, port) do
      {:error, :eaddrinuse} when retries > 0 ->
        Process.sleep(50)
        start_endpoint(port, retries - 1)

      result ->
        result
    end
  end

  @doc "Stop the gRPC endpoint."
  def stop_endpoint, do: GRPC.Server.stop_endpoint(FakeFlintlock.Endpoint)

  @doc "Reset the in-memory store (between tests)."
  def reset, do: Agent.update(@store, fn _ -> %{} end)

  @doc "Raw count of stored VMs."
  def count, do: Agent.get(@store, &map_size/1)

  # --- Store access (used by the Server impl) -------------------------------

  def put(uid, mv), do: Agent.update(@store, &Map.put(&1, uid, mv))
  def fetch(uid), do: Agent.get(@store, &Map.get(&1, uid))
  def drop(uid), do: Agent.update(@store, &Map.delete(&1, uid))
  def all, do: Agent.get(@store, &Map.values(&1))

  @doc "Mint a flintlock-style unique id."
  def mint_uid, do: "uid-" <> Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)

  @doc "Build a CREATED MicroVM from an incoming spec, assigning a uid."
  def materialize(%Types.MicroVMSpec{} = spec) do
    uid = mint_uid()
    id = if spec.id in [nil, ""], do: "mvm-" <> uid, else: spec.id
    spec = %{spec | uid: uid, id: id}

    mv = %Types.MicroVM{
      version: 1,
      spec: spec,
      status: %Types.MicroVMStatus{state: :CREATED}
    }

    {uid, mv}
  end
end

defmodule FakeFlintlock.Endpoint do
  @moduledoc false
  use GRPC.Endpoint

  # Reuse Brigade's auth interceptor so south-edge auth can be tested: the fake
  # gates on :fake_flintlock_token (nil = disabled).
  intercept(Brigade.GRPC.AuthInterceptor, token_key: :fake_flintlock_token)
  run(FakeFlintlock.Server)
end

defmodule FakeFlintlock.Server do
  @moduledoc "gRPC MicroVM service implementation backed by FakeFlintlock's Agent store."
  use GRPC.Server, service: Microvm.Services.Api.V1alpha1.MicroVM.Service

  alias Microvm.Services.Api.V1alpha1, as: Api

  @spec create_micro_vm(Api.CreateMicroVMRequest.t(), GRPC.Server.Stream.t()) ::
          Api.CreateMicroVMResponse.t()
  def create_micro_vm(%Api.CreateMicroVMRequest{microvm: spec}, _stream) do
    unless spec,
      do: raise(GRPC.RPCError, status: :invalid_argument, message: "microvm spec required")

    {uid, mv} = FakeFlintlock.materialize(spec)
    FakeFlintlock.put(uid, mv)
    %Api.CreateMicroVMResponse{microvm: mv}
  end

  def get_micro_vm(%Api.GetMicroVMRequest{uid: uid}, _stream) do
    case FakeFlintlock.fetch(uid) do
      nil -> raise GRPC.RPCError, status: :not_found, message: "microvm #{uid} not found"
      mv -> %Api.GetMicroVMResponse{microvm: mv}
    end
  end

  def delete_micro_vm(%Api.DeleteMicroVMRequest{uid: uid}, _stream) do
    FakeFlintlock.drop(uid)
    %Google.Protobuf.Empty{}
  end

  def list_micro_v_ms(%Api.ListMicroVMsRequest{namespace: ns, name: name}, _stream) do
    %Api.ListMicroVMsResponse{microvm: matching(ns, name)}
  end

  def list_micro_v_ms_stream(%Api.ListMicroVMsRequest{namespace: ns, name: name}, stream) do
    Enum.each(matching(ns, name), fn mv ->
      GRPC.Server.send_reply(stream, %Api.ListMessage{microvm: mv})
    end)
  end

  defp matching(ns, name) do
    FakeFlintlock.all()
    |> Enum.filter(fn %{spec: s} -> s.namespace == ns end)
    |> filter_name(name)
  end

  defp filter_name(vms, nil), do: vms
  defp filter_name(vms, ""), do: vms
  defp filter_name(vms, name), do: Enum.filter(vms, fn %{spec: s} -> s.id == name end)
end
