defmodule Brigade.OvercommitTest do
  @moduledoc """
  The core invariant (plan Q4/Q5/Q9): under concurrent CreateMicroVM load, the
  single serializing scheduler must NEVER place more than a host can hold. If
  this breaks, guests boot on overcommitted RAM and OOM — worse than refusing.

  Proven here by hammering many concurrent creates at one host and asserting
  committed allocation never exceeds capacity.
  """
  use ExUnit.Case, async: false

  alias Microvm.Services.Api.V1alpha1, as: Api
  alias Flintlock.Types
  alias Brigade.{Host, Store.Mnesia}

  @flintlock_port 59_093
  @brigade_port 59_094
  @host_id "host-oc"

  setup do
    start_supervised!(FakeFlintlock.store_child_spec())
    {:ok, _, _} = FakeFlintlock.start_endpoint(@flintlock_port)
    on_exit(&FakeFlintlock.stop_endpoint/0)
    FakeFlintlock.reset()

    {:ok, _, _} = GRPC.Server.start_endpoint(Brigade.GRPC.Endpoint, @brigade_port)
    on_exit(fn -> GRPC.Server.stop_endpoint(Brigade.GRPC.Endpoint) end)

    :mnesia.clear_table(:brigade_vms)
    :mnesia.clear_table(:brigade_hosts)

    {:ok, channel} = GRPC.Stub.connect("localhost:#{@brigade_port}")
    on_exit(fn -> GRPC.Stub.disconnect(channel) end)
    {:ok, channel: channel}
  end

  defp put_host(vcpu, memory_mb) do
    Mnesia.put_host(%Host{
      id: @host_id,
      node: node(),
      endpoint: "localhost:#{@flintlock_port}",
      labels: %{},
      capacity: %{vcpu: vcpu, memory_mb: memory_mb},
      reserve: %{vcpu: 0, memory_mb: 0},
      providers: [],
      status: :available
    })
  end

  defp create(channel, id, vcpu, mem) do
    spec = %Types.MicroVMSpec{
      id: id,
      namespace: "ns",
      vcpu: vcpu,
      memory_in_mb: mem,
      kernel: %Types.Kernel{image: "k"}
    }

    Api.MicroVM.Stub.create_micro_vm(channel, %Api.CreateMicroVMRequest{microvm: spec})
  end

  defp committed_vcpu do
    {:ok, recs} = Mnesia.list_vms_on_host(@host_id)
    Enum.sum(Enum.map(recs, & &1.vcpu))
  end

  defp fire(channel, specs) do
    specs
    |> Task.async_stream(fn {id, vcpu, mem} -> create(channel, id, vcpu, mem) end,
      max_concurrency: 32,
      timeout: 30_000
    )
    |> Enum.map(fn {:ok, res} -> res end)
  end

  test "uniform concurrent creates fill a host exactly, never over", %{channel: channel} do
    cap = 16
    put_host(cap, 1_000_000)

    results = fire(channel, for(i <- 1..60, do: {"vm#{i}", 1, 1}))
    oks = Enum.count(results, &match?({:ok, _}, &1))
    rejected = Enum.count(results, &match?({:error, %GRPC.RPCError{status: 8}}, &1))

    assert oks == cap, "expected exactly #{cap} placements, got #{oks}"
    assert oks + rejected == 60
    assert FakeFlintlock.count() == cap
    assert committed_vcpu() == cap
    assert committed_vcpu() <= cap
  end

  test "varied-size concurrent creates never exceed capacity", %{channel: channel} do
    cap = 16
    put_host(cap, 1_000_000)

    specs = for i <- 1..40, do: {"vm#{i}", :rand.uniform(4), 1}
    _results = fire(channel, specs)

    total = committed_vcpu()
    assert total <= cap, "committed #{total} exceeded capacity #{cap}"
    assert FakeFlintlock.count() == length(elem(Mnesia.list_vms_on_host(@host_id), 1))
  end

  test "freed capacity (delete) is reusable under contention", %{channel: channel} do
    cap = 4
    put_host(cap, 1_000_000)

    # Fill it.
    fill = fire(channel, for(i <- 1..4, do: {"f#{i}", 1, 1}))
    uids = for {:ok, %{microvm: mv}} <- fill, do: mv.spec.uid
    assert length(uids) == 4
    assert match?({:error, %GRPC.RPCError{status: 8}}, create(channel, "over", 1, 1))

    # Delete two, then two more should fit — and still no overcommit.
    for uid <- Enum.take(uids, 2) do
      {:ok, _} = Api.MicroVM.Stub.delete_micro_vm(channel, %Api.DeleteMicroVMRequest{uid: uid})
    end

    again = fire(channel, [{"n1", 1, 1}, {"n2", 1, 1}, {"n3", 1, 1}])
    assert Enum.count(again, &match?({:ok, _}, &1)) == 2
    assert committed_vcpu() <= cap
  end
end
