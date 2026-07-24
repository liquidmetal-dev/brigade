defmodule Brigade.ObservabilityTest do
  @moduledoc "M4 telemetry events, gauge poller, status snapshot, and status HTTP router."
  use ExUnit.Case, async: false
  import Plug.Test

  alias Brigade.{Host, Store.Mnesia, Scheduler, Status}

  setup do
    :mnesia.clear_table(:brigade_vms)
    :mnesia.clear_table(:brigade_hosts)
    :ok
  end

  defp host(id, vcpu, mem, status \\ :available) do
    %Host{
      id: id,
      node: Node.self(),
      endpoint: "localhost:9090",
      capacity: %{vcpu: vcpu, memory_mb: mem},
      reserve: %{vcpu: 0, memory_mb: 0},
      status: status
    }
  end

  defp attach(events) do
    ref = make_ref()
    handler = "test-#{inspect(ref)}"
    test = self()

    :telemetry.attach_many(
      handler,
      events,
      fn name, meas, meta, _ -> send(test, {:event, name, meas, meta}) end,
      nil
    )

    on_exit(fn -> :telemetry.detach(handler) end)
  end

  test "scheduler emits placed and rejected events" do
    attach([[:brigade, :schedule, :placed], [:brigade, :schedule, :rejected]])

    sched =
      start_supervised!(%{id: :ob_sched, start: {Scheduler, :start_link, [[name: :ob_sched]]}})

    :ok = Mnesia.put_host(host("h1", 4, 4096))

    demand = %{vcpu: 2, memory_mb: 1024, provider: nil, constraints: %{}}
    assert {:ok, _} = Scheduler.reserve(demand, sched)
    assert_receive {:event, [:brigade, :schedule, :placed], %{vcpu: 2}, %{host_id: "h1"}}

    big = %{vcpu: 999, memory_mb: 1, provider: nil, constraints: %{}}
    assert {:error, :no_capacity} = Scheduler.reserve(big, sched)
    assert_receive {:event, [:brigade, :schedule, :rejected], _, %{reason: :no_capacity}}
  end

  test "poller emits capacity and partition gauges" do
    attach([[:brigade, :host, :capacity], [:brigade, :partition]])
    :ok = Mnesia.put_host(host("h2", 8, 8192))

    poller =
      start_supervised!(%{
        id: :ob_poll,
        start: {Brigade.Telemetry.Poller, :start_link, [[interval_ms: 3_600_000]]}
      })

    :ok = Brigade.Telemetry.Poller.poll_now(poller)

    assert_receive {:event, [:brigade, :host, :capacity], %{free_vcpu: 8, vm_count: 0},
                    %{host_id: "h2"}}

    assert_receive {:event, [:brigade, :partition], %{size: size, in_quorum: 1}, _} when size >= 1
  end

  test "status snapshot reports capacity and quorum" do
    :ok = Mnesia.put_host(host("h3", 8, 8192))

    Mnesia.put_vm(%Brigade.VMRecord{
      uid: "u1",
      namespace: "ns",
      host_id: "h3",
      vcpu: 3,
      memory_mb: 1024,
      state: :created
    })

    snap = Status.snapshot()

    assert snap.partition.in_quorum == true
    assert snap.schedulable_hosts == 1
    assert snap.flintlock_api_version == "v0.11.0"
    h = Enum.find(snap.hosts, &(&1.id == "h3"))
    assert h.committed.vcpu == 3
    assert h.free.vcpu == 5
    assert h.vm_count == 1
  end

  test "status router serves /status and /healthz" do
    :ok = Mnesia.put_host(host("h4", 2, 2048))

    status = conn(:get, "/status") |> Brigade.Status.Router.call([])
    assert status.status == 200
    body = Jason.decode!(status.resp_body)
    assert body["schedulable_hosts"] == 1
    assert body["flintlock_api_version"] == "v0.11.0"

    health = conn(:get, "/healthz") |> Brigade.Status.Router.call([])
    assert health.status == 200
    assert Jason.decode!(health.resp_body)["ok"] == true

    missing = conn(:get, "/nope") |> Brigade.Status.Router.call([])
    assert missing.status == 404
  end
end
