defmodule Brigade.FailureHandlingTest do
  @moduledoc """
  M3 failure handling, exercised hermetically:

    * reconciler adopts orphans, marks lost, syncs state, cleans :unknown
    * health monitor flips local host available/unreachable on flintlock reachability
    * quorum gate refuses placement in a sub-quorum partition
    * nodedown marks a host unreachable + flags its VMs
  """
  use ExUnit.Case, async: false

  alias Flintlock.Types
  alias Microvm.Services.Api.V1alpha1, as: Api
  alias Brigade.{Host, VMRecord, Store.Mnesia, Scheduler}

  @flintlock_port 59_095
  @local_id "local-host"

  setup do
    :mnesia.clear_table(:brigade_vms)
    :mnesia.clear_table(:brigade_hosts)
    :ok
  end

  defp local_host(status \\ :available) do
    %Host{
      id: @local_id,
      node: Node.self(),
      endpoint: "localhost:#{@flintlock_port}",
      labels: %{},
      capacity: %{vcpu: 8, memory_mb: 8192},
      reserve: %{vcpu: 0, memory_mb: 0},
      providers: [],
      status: status
    }
  end

  defp fake_vm(uid, id, ns, state \\ :CREATED) do
    %Types.MicroVM{
      version: 1,
      spec: %Types.MicroVMSpec{uid: uid, id: id, namespace: ns, vcpu: 2, memory_in_mb: 512},
      status: %Types.MicroVMStatus{state: state}
    }
  end

  defp start_fake do
    start_supervised!(FakeFlintlock.store_child_spec())
    {:ok, _, _} = FakeFlintlock.start_endpoint(@flintlock_port)
    on_exit(&FakeFlintlock.stop_endpoint/0)
    FakeFlintlock.reset()
  end

  describe "reconciler" do
    setup do
      start_fake()
      :ok = Mnesia.put_host(local_host())
      start_supervised!({Brigade.LocalFlintlock.Reconciler, interval_ms: 3_600_000})
      :ok
    end

    test "adopts orphans, marks lost, syncs state, and cleans :unknown placeholders" do
      # Orphan on flintlock in "ns" — discoverable because an :unknown placeholder
      # lives in that namespace (the ambiguous-create resolution path).
      FakeFlintlock.put("orphan1", fake_vm("orphan1", "o1", "ns"))

      Mnesia.put_vm(%VMRecord{
        uid: "unk1",
        namespace: "ns",
        host_id: @local_id,
        state: :unknown
      })

      # Lost: in store, gone from flintlock (namespace "ns2").
      Mnesia.put_vm(%VMRecord{
        uid: "lost1",
        namespace: "ns2",
        name: "l1",
        host_id: @local_id,
        vcpu: 1,
        memory_mb: 256,
        state: :created
      })

      # Mismatch: present on both, flintlock says FAILED (namespace "ns3").
      FakeFlintlock.put("sync1", fake_vm("sync1", "s1", "ns3", :FAILED))

      Mnesia.put_vm(%VMRecord{
        uid: "sync1",
        namespace: "ns3",
        name: "s1",
        host_id: @local_id,
        vcpu: 2,
        memory_mb: 512,
        state: :created
      })

      summary = Brigade.LocalFlintlock.Reconciler.reconcile_now()

      assert summary.adopted == 1
      assert summary.lost == 1
      assert summary.synced == 1

      assert {:ok, adopted} = Mnesia.get_vm("orphan1")
      assert adopted.state == :created
      assert adopted.host_id == @local_id
      assert adopted.vcpu == 2

      assert {:ok, %{state: :lost}} = Mnesia.get_vm("lost1")
      assert {:ok, %{state: :failed}} = Mnesia.get_vm("sync1")
      # Placeholder resolved and removed.
      assert {:error, :not_found} = Mnesia.get_vm("unk1")
    end
  end

  describe "health monitor (dual-liveness)" do
    test "reports available when flintlock answers, unreachable when it doesn't" do
      start_fake()
      :ok = Mnesia.put_host(local_host(:unreachable))
      start_supervised!({Brigade.LocalFlintlock.HealthMonitor, interval_ms: 3_600_000})

      assert Brigade.LocalFlintlock.HealthMonitor.check_now() == :available
      assert {:ok, %{status: :available}} = Mnesia.get_host(@local_id)

      # flintlock goes away -> unreachable.
      FakeFlintlock.stop_endpoint()
      assert Brigade.LocalFlintlock.HealthMonitor.check_now() == :unreachable
      assert {:ok, %{status: :unreachable}} = Mnesia.get_host(@local_id)
    end
  end

  describe "quorum gate (split-brain guard)" do
    test "sub-quorum partition refuses placement; quorum partition allows it" do
      minority =
        start_supervised!(%{
          id: :minority_sched,
          start: {Scheduler, :start_link, [[name: :minority_sched, min_cluster_size: 5]]}
        })

      majority =
        start_supervised!(%{
          id: :majority_sched,
          start: {Scheduler, :start_link, [[name: :majority_sched, min_cluster_size: 1]]}
        })

      :ok = Mnesia.put_host(local_host())
      demand = %{vcpu: 1, memory_mb: 1, provider: nil, constraints: %{}}

      # Single test node cannot reach a cluster of 5 -> refused.
      assert {:error, :no_quorum} = Scheduler.reserve(demand, minority)
      # min_cluster_size 1 -> always in quorum -> placement proceeds.
      assert {:ok, %{host: %{id: @local_id}}} = Scheduler.reserve(demand, majority)
    end
  end

  describe "scheduler unavailable (singleton absent mid-failover)" do
    # Any unregistered name resolves to no process, so GenServer.call exits :noproc —
    # exactly the failure the gRPC edge sees while the Horde singleton is re-homing.
    @dead_server :no_such_scheduler_proc

    test "reserve maps a dead scheduler to {:error, :scheduler_unavailable}" do
      demand = %{vcpu: 1, memory_mb: 1, provider: nil, constraints: %{}}
      assert {:error, :scheduler_unavailable} = Scheduler.reserve(demand, @dead_server)
    end

    test "confirm/release are best-effort and return :ok when the scheduler is gone" do
      record = %VMRecord{uid: "u1", namespace: "ns", host_id: @local_id, state: :created}
      assert :ok = Scheduler.confirm(make_ref(), record, @dead_server)
      assert :ok = Scheduler.release(make_ref(), @dead_server)
    end

    test "create_micro_vm raises UNAVAILABLE (not an uncaught exit) when scheduler is absent" do
      prev = Application.get_env(:brigade, :scheduler)
      Application.put_env(:brigade, :scheduler, @dead_server)
      on_exit(fn -> restore_env(:scheduler, prev) end)

      req = %Api.CreateMicroVMRequest{
        microvm: %Types.MicroVMSpec{vcpu: 1, memory_in_mb: 512}
      }

      err = assert_raise GRPC.RPCError, fn -> Brigade.GRPC.Server.create_micro_vm(req, nil) end
      assert err.status == GRPC.Status.unavailable()
    end

    defp restore_env(_key, nil), do: Application.delete_env(:brigade, :scheduler)
    defp restore_env(key, val), do: Application.put_env(:brigade, key, val)
  end

  describe "nodedown" do
    test "marks a dead node's host unreachable and flags its VMs" do
      sched =
        start_supervised!(%{
          id: :nd_sched,
          start: {Scheduler, :start_link, [[name: :nd_sched, min_cluster_size: 1]]}
        })

      dead_node = :"gone@127.0.0.1"

      Mnesia.put_host(%{local_host() | id: "remote-host", node: dead_node})

      Mnesia.put_vm(%VMRecord{
        uid: "v-on-dead",
        namespace: "ns",
        name: "v",
        host_id: "remote-host",
        vcpu: 2,
        memory_mb: 512,
        state: :created
      })

      send(sched, {:nodedown, dead_node})
      # Flush the async handle_info before asserting.
      :sys.get_state(sched)

      assert {:ok, %{status: :unreachable}} = Mnesia.get_host("remote-host")
      assert {:ok, %{state: :unreachable}} = Mnesia.get_vm("v-on-dead")
    end
  end
end
