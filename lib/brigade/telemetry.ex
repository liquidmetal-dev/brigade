defmodule Brigade.Telemetry do
  @moduledoc """
  Observability: a Prometheus scrape endpoint over Brigade's `:telemetry` events,
  plus a poller that periodically emits capacity/partition gauges derived from
  `Brigade.Status`.

  The event-driven metrics (placements, rejections, reconcile drift, host
  up/down) and the polled gauges (per-host free capacity, partition size,
  quorum) together cover the exact failure modes the design guards against:
  overcommit, split-brain, and host loss.
  """
  import Telemetry.Metrics

  @doc "Child specs for the prometheus exporter + the gauge poller."
  def child_specs do
    port = Application.get_env(:brigade, :metrics_port, 9568)

    [
      {TelemetryMetricsPrometheus, metrics: metrics(), port: port, name: :brigade_prometheus},
      Brigade.Telemetry.Poller
    ]
  end

  @doc "Telemetry.Metrics definitions exposed via prometheus."
  def metrics do
    [
      counter("brigade.schedule.placed.count",
        event_name: [:brigade, :schedule, :placed],
        measurement: :vcpu,
        tags: [:host_id]
      ),
      counter("brigade.schedule.rejected.count",
        event_name: [:brigade, :schedule, :rejected],
        measurement: :vcpu,
        tags: [:reason]
      ),
      sum("brigade.reconcile.adopted.total",
        event_name: [:brigade, :reconcile, :stop],
        measurement: :adopted,
        tags: [:host_id]
      ),
      sum("brigade.reconcile.lost.total",
        event_name: [:brigade, :reconcile, :stop],
        measurement: :lost,
        tags: [:host_id]
      ),
      last_value("brigade.host.up",
        event_name: [:brigade, :host, :status],
        measurement: :up,
        tags: [:host_id]
      ),
      # Polled gauges (Brigade.Telemetry.Poller):
      last_value("brigade.host.free_vcpu",
        event_name: [:brigade, :host, :capacity],
        measurement: :free_vcpu,
        tags: [:host_id]
      ),
      last_value("brigade.host.free_memory_mb",
        event_name: [:brigade, :host, :capacity],
        measurement: :free_memory_mb,
        tags: [:host_id]
      ),
      last_value("brigade.host.vm_count",
        event_name: [:brigade, :host, :capacity],
        measurement: :vm_count,
        tags: [:host_id]
      ),
      last_value("brigade.partition.size", event_name: [:brigade, :partition], measurement: :size),
      last_value("brigade.partition.in_quorum",
        event_name: [:brigade, :partition],
        measurement: :in_quorum
      ),
      last_value("brigade.schedulable_hosts",
        event_name: [:brigade, :partition],
        measurement: :schedulable_hosts
      )
    ]
  end
end

defmodule Brigade.Telemetry.Poller do
  @moduledoc "Periodically emits capacity + partition gauges from Brigade.Status."
  use GenServer

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @doc "Emit gauges once (also used by tests)."
  def poll_now(server \\ __MODULE__), do: GenServer.call(server, :poll)

  @impl true
  def init(opts) do
    interval =
      Keyword.get(opts, :interval_ms, Application.get_env(:brigade, :metrics_poll_ms, 10_000))

    # Emit once immediately so the first prometheus scrape after boot is populated.
    emit()
    schedule(interval)
    {:ok, %{interval: interval}}
  end

  @impl true
  def handle_call(:poll, _from, state) do
    emit()
    {:reply, :ok, state}
  end

  @impl true
  def handle_info(:tick, state) do
    emit()
    schedule(state.interval)
    {:noreply, state}
  end

  defp schedule(interval), do: Process.send_after(self(), :tick, interval)

  defp emit do
    snapshot = Brigade.Status.snapshot()

    Enum.each(snapshot.hosts, fn h ->
      :telemetry.execute(
        [:brigade, :host, :capacity],
        %{free_vcpu: h.free.vcpu, free_memory_mb: h.free.memory_mb, vm_count: h.vm_count},
        %{host_id: h.id}
      )
    end)

    :telemetry.execute(
      [:brigade, :partition],
      %{
        size: snapshot.partition.size,
        in_quorum: if(snapshot.partition.in_quorum, do: 1, else: 0),
        schedulable_hosts: snapshot.schedulable_hosts
      },
      %{}
    )
  end
end
