defmodule Brigade.LocalFlintlock.HealthMonitor do
  @moduledoc """
  Second half of dual-liveness: even when the Erlang node is up, the local
  `flintlockd` may be down. This periodically probes the co-located flintlock and
  flips the local host between `:available` and `:unreachable` accordingly.

  Combined with the scheduler's `nodedown` handling, a host is schedulable only
  when BOTH its node is connected AND its flintlock answers.
  """
  use GenServer
  require Logger

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @doc "Run one probe synchronously (tests)."
  def check_now(server \\ __MODULE__), do: GenServer.call(server, :check)

  @impl true
  def init(opts) do
    interval =
      Keyword.get(opts, :interval_ms, Application.get_env(:brigade, :health_interval_ms, 5_000))

    schedule(interval)
    {:ok, %{interval: interval}}
  end

  @impl true
  def handle_call(:check, _from, state) do
    {:reply, probe(), state}
  end

  @impl true
  def handle_info(:tick, state) do
    probe()
    schedule(state.interval)
    {:noreply, state}
  end

  defp schedule(interval), do: Process.send_after(self(), :tick, interval)

  # Returns the new status, updating the store only on change.
  defp probe do
    case Brigade.LocalFlintlock.local_host() do
      {:ok, host} ->
        status = if reachable?(host), do: :available, else: :unreachable

        if host.status != status do
          Logger.info("local flintlock #{host.endpoint}: #{host.status} -> #{status}")
          Brigade.LocalFlintlock.store().put_host(%{host | status: status})

          :telemetry.execute(
            [:brigade, :host, :status],
            %{up: if(status == :available, do: 1, else: 0)},
            %{host_id: host.id, status: status}
          )
        end

        status

      :error ->
        :no_local_host
    end
  end

  # Fast TCP probe of the flintlock endpoint — a refused/absent listener returns
  # immediately, so a slow gRPC dial never stalls the monitor (plan: TCP :9090 ping).
  defp reachable?(host) do
    timeout = Application.get_env(:brigade, :health_probe_timeout_ms, 1_000)

    with [h, p] <- String.split(host.endpoint, ":", parts: 2),
         {port, ""} <- Integer.parse(p),
         {:ok, sock} <-
           :gen_tcp.connect(String.to_charlist(h), port, [:binary, active: false], timeout) do
      :gen_tcp.close(sock)
      true
    else
      _ -> false
    end
  end
end
