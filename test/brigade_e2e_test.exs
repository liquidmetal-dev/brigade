defmodule BrigadeE2ETest do
  @moduledoc """
  M1 exit criterion: a client speaking the flintlock gRPC interface to *Brigade*
  gets a microVM created on a host's flintlock, and Get/List/Delete round-trip
  end-to-end. The client can't tell Brigade from a real flintlockd.

  Topology: client -> Brigade north endpoint (:59092) -> HostDriver.Local ->
  fake flintlock (:59091). Brigade's Scheduler + Mnesia store are app-started.
  """
  use ExUnit.Case, async: false

  alias Microvm.Services.Api.V1alpha1, as: Api
  alias Flintlock.Types
  alias Brigade.{Host, Store.Mnesia}

  @flintlock_port 59_091
  @brigade_port 59_092
  @host_id "host-test"

  setup do
    # Fake flintlock (south) + Brigade north endpoint.
    start_supervised!(FakeFlintlock.store_child_spec())
    {:ok, _fl_pid, _} = FakeFlintlock.start_endpoint(@flintlock_port)
    on_exit(&FakeFlintlock.stop_endpoint/0)
    FakeFlintlock.reset()

    {:ok, _br_pid, _} = GRPC.Server.start_endpoint(Brigade.GRPC.Endpoint, @brigade_port)
    on_exit(fn -> GRPC.Server.stop_endpoint(Brigade.GRPC.Endpoint) end)

    # Fresh state each test; register a single host pointing at the fake flintlock.
    :mnesia.clear_table(:brigade_vms)
    :mnesia.clear_table(:brigade_hosts)
    :ok = Mnesia.put_host(test_host(vcpu: 8, memory_mb: 16_384))

    {:ok, channel} = GRPC.Stub.connect("localhost:#{@brigade_port}")
    on_exit(fn -> GRPC.Stub.disconnect(channel) end)
    {:ok, channel: channel}
  end

  defp test_host(cap) do
    %Host{
      id: @host_id,
      node: node(),
      endpoint: "localhost:#{@flintlock_port}",
      labels: %{},
      capacity: %{vcpu: cap[:vcpu], memory_mb: cap[:memory_mb]},
      reserve: %{vcpu: 0, memory_mb: 0},
      providers: [],
      status: :available
    }
  end

  defp create(channel, overrides) do
    spec =
      struct(
        %Types.MicroVMSpec{
          id: "",
          namespace: "ns1",
          vcpu: 2,
          memory_in_mb: 1024,
          kernel: %Types.Kernel{image: "ghcr.io/example/kernel:latest"}
        },
        overrides
      )

    Api.MicroVM.Stub.create_micro_vm(channel, %Api.CreateMicroVMRequest{microvm: spec})
  end

  test "create places the VM on a host and returns flintlock's uid", %{channel: channel} do
    assert {:ok, %Api.CreateMicroVMResponse{microvm: mv}} = create(channel, id: "vm1")
    assert mv.spec.uid =~ ~r/^uid-[0-9a-f]{16}$/
    assert mv.status.state == :CREATED

    # The VM really exists on the (fake) flintlock, and Brigade recorded the placement.
    assert FakeFlintlock.count() == 1
    assert {:ok, rec} = Mnesia.get_vm(mv.spec.uid)
    assert rec.host_id == @host_id
    assert rec.state == :created
  end

  test "get round-trips through Brigade to the host", %{channel: channel} do
    {:ok, %{microvm: mv}} = create(channel, id: "vm2")
    uid = mv.spec.uid

    assert {:ok, %Api.GetMicroVMResponse{microvm: got}} =
             Api.MicroVM.Stub.get_micro_vm(channel, %Api.GetMicroVMRequest{uid: uid})

    assert got.spec.uid == uid
  end

  test "list is answered from Brigade's state store", %{channel: channel} do
    {:ok, _} = create(channel, id: "a", namespace: "ns1")
    {:ok, _} = create(channel, id: "b", namespace: "ns1")
    {:ok, _} = create(channel, id: "c", namespace: "ns2")

    {:ok, %{microvm: ns1}} =
      Api.MicroVM.Stub.list_micro_v_ms(channel, %Api.ListMicroVMsRequest{namespace: "ns1"})

    assert length(ns1) == 2
    assert Enum.all?(ns1, &(&1.spec.namespace == "ns1"))
  end

  test "delete removes the VM from host and store (idempotent)", %{channel: channel} do
    {:ok, %{microvm: mv}} = create(channel, id: "vm3")
    uid = mv.spec.uid

    assert {:ok, %Google.Protobuf.Empty{}} =
             Api.MicroVM.Stub.delete_micro_vm(channel, %Api.DeleteMicroVMRequest{uid: uid})

    assert FakeFlintlock.count() == 0
    assert {:error, :not_found} = Mnesia.get_vm(uid)

    # Idempotent: deleting an unknown uid still returns Empty.
    assert {:ok, %Google.Protobuf.Empty{}} =
             Api.MicroVM.Stub.delete_micro_vm(channel, %Api.DeleteMicroVMRequest{uid: uid})
  end

  test "scheduler refuses placement when the host is full", %{channel: channel} do
    # Host has 8 vcpu; two 4-vcpu VMs fill it, the third is rejected.
    assert {:ok, _} = create(channel, id: "big1", vcpu: 4)
    assert {:ok, _} = create(channel, id: "big2", vcpu: 4)

    assert {:error, %GRPC.RPCError{status: 8}} = create(channel, id: "big3", vcpu: 4)
    assert FakeFlintlock.count() == 2
  end
end
