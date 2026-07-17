defmodule Brigade.Scheduler do
  @moduledoc """
  Placement authority. M1 runs it as a plain local GenServer; M2 wraps the same
  process as a Horde-managed cluster singleton so exactly one exists mesh-wide.

  Capacity accounting is split:

    * **committed** — VMs already `:created`, read from `Brigade.Store`
      (survives scheduler restart).
    * **in-flight** — reservations for creates currently being forwarded, held
      in this process's memory (lost on restart; those creates were ambiguous
      anyway and get settled by reconcile in M3).

  The reserve/confirm/release split keeps the singleton non-blocking: reserving
  is fast and serialized here; the multi-second flintlock `CreateMicroVM` happens
  in the caller (the gRPC handler), then confirms or releases by `ref`. This
  serialization is what makes "no host overcommits" hold under concurrency.
  """
  use GenServer
  require Logger

  alias Brigade.{Host, VMRecord}

  @constraint_prefix "brigade.scheduling/"

  # Horde registry that holds the cluster-wide singleton registration.
  @registry Brigade.Scheduler.Registry
  @singleton_key :singleton

  # --- client API -----------------------------------------------------------

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: name(opts))

  # Default name is the Horde via-tuple → the process registers as the mesh-wide
  # singleton. Tests can pass `name: SomeAtom` to run an isolated plain instance.
  defp name(opts), do: Keyword.get(opts, :name, via())

  @doc "Via-tuple resolving to the cluster-singleton scheduler through Horde.Registry."
  def via, do: {:via, Horde.Registry, {@registry, @singleton_key}}

  @doc "The Horde.Registry name (started by the cluster supervisor stack)."
  def registry, do: @registry

  @typedoc "What a CreateMicroVM asks of a host."
  @type demand :: Brigade.Scheduler.Strategy.demand()

  @doc """
  Reserve capacity for a demand. Returns the chosen host + a ref to confirm/release.

  If the singleton is momentarily absent (mid-failover), the `GenServer.call` exits
  with `:noproc`; we catch that and return `{:error, :scheduler_unavailable}` so the
  gRPC edge can surface a retryable `UNAVAILABLE` instead of a raw `UNKNOWN`.
  """
  @spec reserve(demand(), GenServer.server()) ::
          {:ok, %{host: Host.t(), ref: reference()}}
          | {:error, :no_capacity | :no_hosts | :no_quorum | :scheduler_unavailable}
  def reserve(demand, server \\ via()), do: safe_call(server, {:reserve, demand})

  @doc """
  Confirm a reservation: persist the created VM record, drop the in-flight hold.

  Best-effort: by confirm time the VM already exists on the host, so a scheduler
  that died mid-create must not fail the whole RPC. On exit we log and return `:ok`;
  the per-host reconciler adopts the (then un-persisted) VM.
  """
  @spec confirm(reference(), VMRecord.t(), GenServer.server()) :: :ok
  def confirm(ref, %VMRecord{} = record, server \\ via()),
    do: best_effort_call(server, {:confirm, ref, record})

  @doc "Release a reservation (create failed): drop the in-flight hold, no record persisted."
  @spec release(reference(), GenServer.server()) :: :ok
  def release(ref, server \\ via()), do: best_effort_call(server, {:release, ref})

  # Map a dead/absent singleton (`:exit` from the via-tuple call) to a typed error.
  defp safe_call(server, msg) do
    GenServer.call(server, msg)
  catch
    :exit, _reason -> {:error, :scheduler_unavailable}
  end

  # Post-reserve calls where the create already happened: swallow a dead scheduler.
  defp best_effort_call(server, msg) do
    GenServer.call(server, msg)
  catch
    :exit, reason ->
      Logger.warning("scheduler unavailable for #{inspect(elem(msg, 0))}: #{inspect(reason)}")
      :ok
  end

  @doc "Build a demand from an incoming CreateMicroVM spec."
  @spec demand_from_spec(Flintlock.Types.MicroVMSpec.t()) :: demand()
  def demand_from_spec(spec) do
    %{
      vcpu: spec.vcpu,
      memory_mb: spec.memory_in_mb,
      provider: spec.provider,
      constraints: extract_constraints(spec.labels || %{})
    }
  end

  defp extract_constraints(labels) do
    for {k, v} <- labels, String.starts_with?(k, @constraint_prefix), into: %{} do
      {String.replace_prefix(k, @constraint_prefix, ""), v}
    end
  end

  # --- server ---------------------------------------------------------------

  @impl true
  def init(opts) do
    strategy = Keyword.get(opts, :strategy, Brigade.Scheduler.Strategy.LeastLoaded)
    store = Keyword.get(opts, :store, Brigade.Store.Mnesia)

    min_cluster_size =
      Keyword.get(opts, :min_cluster_size, Application.get_env(:brigade, :min_cluster_size, 1))

    # Watch the mesh so we can mark hosts unreachable when their node dies.
    :net_kernel.monitor_nodes(true)

    state = %{
      strategy: strategy,
      store: store,
      min_cluster_size: min_cluster_size,
      # in_flight: %{ref => {host_id, vcpu, memory_mb}}
      in_flight: %{}
    }

    # On failover the scheduler re-homes to a survivor; reconcile host liveness
    # against the current mesh so stale `:available` hosts don't get placements.
    sweep_unreachable(state)
    {:ok, state}
  end

  @impl true
  def handle_call({:reserve, demand}, _from, state) do
    cond do
      not in_quorum?(state) ->
        # Split-brain guard: a minority partition must not place VMs (would
        # overcommit hosts the majority is also scheduling). Reads stay available.
        rejected(:no_quorum, demand)
        {:reply, {:error, :no_quorum}, state}

      true ->
        do_reserve(demand, state)
    end
  end

  @impl true
  def handle_call({:confirm, ref, record}, _from, state) do
    :ok = state.store.put_vm(%{record | state: :created})
    {:reply, :ok, %{state | in_flight: Map.delete(state.in_flight, ref)}}
  end

  @impl true
  def handle_call({:release, ref}, _from, state) do
    {:reply, :ok, %{state | in_flight: Map.delete(state.in_flight, ref)}}
  end

  @impl true
  def handle_info({:nodedown, down}, state) do
    Logger.warning("node #{down} down — marking its hosts unreachable")
    {:noreply, mark_node_unreachable(down, state)}
  end

  @impl true
  def handle_info({:nodeup, up}, state) do
    # The joining node re-registers its own host as available (self-register on
    # boot). Nothing to do here beyond noting it.
    Logger.info("node #{up} up")
    {:noreply, state}
  end

  @impl true
  def handle_info(_msg, state), do: {:noreply, state}

  # --- liveness / quorum ----------------------------------------------------

  defp in_quorum?(state), do: length([Node.self() | Node.list()]) >= state.min_cluster_size

  defp do_reserve(demand, state) do
    case state.store.list_hosts() do
      {:ok, []} ->
        rejected(:no_hosts, demand)
        {:reply, {:error, :no_hosts}, state}

      {:ok, hosts} ->
        candidates = candidates(hosts, state)
        filtered = state.strategy.filter(candidates, demand)

        case state.strategy.score(filtered, demand) do
          {:ok, host} ->
            ref = make_ref()
            hold = {host.id, demand.vcpu, demand.memory_mb}

            :telemetry.execute(
              [:brigade, :schedule, :placed],
              %{vcpu: demand.vcpu, memory_mb: demand.memory_mb},
              %{host_id: host.id, strategy: state.strategy}
            )

            {:reply, {:ok, %{host: host, ref: ref}}, put_in(state.in_flight[ref], hold)}

          :none ->
            rejected(:no_capacity, demand)
            {:reply, {:error, :no_capacity}, state}
        end

      {:error, _reason} ->
        rejected(:no_hosts, demand)
        {:reply, {:error, :no_hosts}, state}
    end
  end

  defp rejected(reason, demand) do
    :telemetry.execute(
      [:brigade, :schedule, :rejected],
      %{vcpu: demand.vcpu, memory_mb: demand.memory_mb},
      %{reason: reason}
    )
  end

  # Mark every host on a dead node unreachable: release its in-flight holds and
  # flag its VMs unreachable (last-known state; adopt-on-return via reconcile).
  defp mark_node_unreachable(down, state) do
    {:ok, hosts} = state.store.list_hosts()
    dead = Enum.filter(hosts, &(&1.node == down))

    Enum.each(dead, fn host ->
      state.store.put_host(%{host | status: :unreachable})
      flag_vms_unreachable(host, state)
    end)

    dead_ids = MapSet.new(dead, & &1.id)

    in_flight =
      for {ref, {hid, _, _} = h} <- state.in_flight,
          not MapSet.member?(dead_ids, hid),
          into: %{},
          do: {ref, h}

    %{state | in_flight: in_flight}
  end

  # Sweep at init (failover): any host whose node isn't currently connected is unreachable.
  defp sweep_unreachable(state) do
    connected = MapSet.new([Node.self() | Node.list()])

    case state.store.list_hosts() do
      {:ok, hosts} ->
        Enum.each(hosts, fn host ->
          cond do
            host.node == nil -> :ok
            MapSet.member?(connected, host.node) -> :ok
            host.status == :unreachable -> :ok
            true -> state.store.put_host(%{host | status: :unreachable})
          end
        end)

      _ ->
        :ok
    end
  end

  defp flag_vms_unreachable(host, state) do
    case state.store.list_vms_on_host(host.id) do
      {:ok, vms} ->
        Enum.each(vms, fn vm ->
          if vm.state == :created, do: state.store.put_vm(%{vm | state: :unreachable})
        end)

      _ ->
        :ok
    end
  end

  # Pair each host with its currently free schedulable capacity.
  defp candidates(hosts, state), do: Enum.map(hosts, &{&1, free(&1, state)})

  defp free(%Host{} = host, state) do
    sched = Host.schedulable(host)
    committed = committed(host, state)
    in_flight = in_flight(host, state)

    %{
      vcpu: sched.vcpu - committed.vcpu - in_flight.vcpu,
      memory_mb: sched.memory_mb - committed.memory_mb - in_flight.memory_mb
    }
  end

  defp committed(%Host{id: id}, state) do
    case state.store.list_vms_on_host(id) do
      {:ok, vms} ->
        vms
        |> Enum.filter(&(&1.state in [:reserved, :creating, :created]))
        |> sum_resources()

      _ ->
        %{vcpu: 0, memory_mb: 0}
    end
  end

  defp in_flight(%Host{id: id}, state) do
    state.in_flight
    |> Map.values()
    |> Enum.filter(fn {h, _, _} -> h == id end)
    |> Enum.reduce(%{vcpu: 0, memory_mb: 0}, fn {_h, v, m}, acc ->
      %{vcpu: acc.vcpu + v, memory_mb: acc.memory_mb + m}
    end)
  end

  defp sum_resources(vms) do
    Enum.reduce(vms, %{vcpu: 0, memory_mb: 0}, fn vm, acc ->
      %{vcpu: acc.vcpu + vm.vcpu, memory_mb: acc.memory_mb + vm.memory_mb}
    end)
  end
end
