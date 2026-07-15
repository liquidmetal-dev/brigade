defmodule FakeFlintlockTest do
  @moduledoc """
  M0 exit criterion: the fake flintlock answers create/get/delete (+ list) over
  real gRPC, using the same generated stubs Brigade's HostDriver will dial.
  This pins the drop-in contract.
  """
  use ExUnit.Case, async: false

  alias Microvm.Services.Api.V1alpha1, as: Api
  alias Flintlock.Types

  @port 59_090

  setup do
    start_supervised!(FakeFlintlock.store_child_spec())
    {:ok, _pid, _port} = FakeFlintlock.start_endpoint(@port)
    on_exit(&FakeFlintlock.stop_endpoint/0)
    FakeFlintlock.reset()
    {:ok, channel} = GRPC.Stub.connect("localhost:#{@port}")
    on_exit(fn -> GRPC.Stub.disconnect(channel) end)
    {:ok, channel: channel}
  end

  defp spec(overrides) do
    base = %Types.MicroVMSpec{
      id: "",
      namespace: "ns1",
      vcpu: 2,
      memory_in_mb: 1024,
      kernel: %Types.Kernel{image: "ghcr.io/example/kernel:latest"}
    }

    struct(base, overrides)
  end

  test "create mints a uid and returns a CREATED microvm", %{channel: channel} do
    req = %Api.CreateMicroVMRequest{microvm: spec(id: "vm1")}

    assert {:ok, %Api.CreateMicroVMResponse{microvm: mv}} =
             Api.MicroVM.Stub.create_micro_vm(channel, req)

    assert mv.status.state == :CREATED
    assert mv.spec.uid =~ ~r/^uid-[0-9a-f]{16}$/
    assert mv.spec.namespace == "ns1"
    assert FakeFlintlock.count() == 1
  end

  test "get by uid round-trips; delete removes it", %{channel: channel} do
    {:ok, %{microvm: mv}} =
      Api.MicroVM.Stub.create_micro_vm(channel, %Api.CreateMicroVMRequest{
        microvm: spec(id: "vm2")
      })

    uid = mv.spec.uid

    assert {:ok, %Api.GetMicroVMResponse{microvm: got}} =
             Api.MicroVM.Stub.get_micro_vm(channel, %Api.GetMicroVMRequest{uid: uid})

    assert got.spec.uid == uid

    assert {:ok, %Google.Protobuf.Empty{}} =
             Api.MicroVM.Stub.delete_micro_vm(channel, %Api.DeleteMicroVMRequest{uid: uid})

    assert {:error, %GRPC.RPCError{status: 5}} =
             Api.MicroVM.Stub.get_micro_vm(channel, %Api.GetMicroVMRequest{uid: uid})
  end

  test "list filters by namespace and name", %{channel: channel} do
    for {id, ns} <- [{"a", "ns1"}, {"b", "ns1"}, {"c", "ns2"}] do
      Api.MicroVM.Stub.create_micro_vm(channel, %Api.CreateMicroVMRequest{
        microvm: spec(id: id, namespace: ns)
      })
    end

    {:ok, %{microvm: ns1}} =
      Api.MicroVM.Stub.list_micro_v_ms(channel, %Api.ListMicroVMsRequest{namespace: "ns1"})

    assert length(ns1) == 2

    {:ok, %{microvm: [only]}} =
      Api.MicroVM.Stub.list_micro_v_ms(channel, %Api.ListMicroVMsRequest{
        namespace: "ns1",
        name: "b"
      })

    assert only.spec.id == "b"
  end
end
