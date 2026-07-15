defmodule Brigade.LocalFlintlock.Reconciler do
  @moduledoc """
  Per-host drift correction (plan Q11). Periodically compares the local
  flintlock's actual VMs against Brigade's records for this host and converges
  Brigade's state to flintlock reality:

    * **orphan** (on flintlock, not in store) — adopt (import a record). This is
      also how ambiguous creates resolve: a timed-out `CreateMicroVM` that in
      fact succeeded shows up as an orphan and gets adopted.
    * **lost** (in store, not on flintlock) — mark `:lost`, releasing capacity.
    * **mismatch** (both, differing state) — sync the record to flintlock's state.

  State-sync only: the reconciler NEVER creates or deletes VMs on flintlock.
  Brigade is not a desired-state controller over guest workloads.

  flintlock's `ListMicroVMs` is per-namespace, so reconciliation covers the
  namespaces Brigade already knows on this host (including `:unknown`
  placeholders) plus any configured extras; orphans in wholly-unknown namespaces
  are not discoverable and are left alone.
  """
  use GenServer
  require Logger

  alias Brigade.VMRecord
  alias Flintlock.Types

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @doc "Run one reconcile pass synchronously (tests). Returns a summary map."
  def reconcile_now(server \\ __MODULE__), do: GenServer.call(server, :reconcile, 30_000)

  @impl true
  def init(opts) do
    interval =
      Keyword.get(
        opts,
        :interval_ms,
        Application.get_env(:brigade, :reconcile_interval_ms, 30_000)
      )

    schedule(interval)
    {:ok, %{interval: interval}}
  end

  @impl true
  def handle_call(:reconcile, _from, state) do
    {:reply, run(), state}
  end

  @impl true
  def handle_info(:tick, state) do
    run()
    schedule(state.interval)
    {:noreply, state}
  end

  defp schedule(interval), do: Process.send_after(self(), :tick, interval)

  # --- reconcile ------------------------------------------------------------

  defp run do
    with {:ok, host} <- Brigade.LocalFlintlock.local_host(),
         {:ok, channel} <- Brigade.LocalFlintlock.driver().connect(host) do
      try do
        namespaces = namespaces(host)

        summary =
          Enum.reduce(namespaces, empty_summary(), fn ns, acc ->
            merge(acc, reconcile_ns(host, channel, ns))
          end)

        cleanup_unknowns(host, namespaces)
        summary
      after
        GRPC.Stub.disconnect(channel)
      end
    else
      _ -> empty_summary()
    end
  end

  defp namespaces(host) do
    extra = Application.get_env(:brigade, :reconcile_namespaces, [])

    case store().list_vms_on_host(host.id) do
      {:ok, vms} -> vms |> Enum.map(& &1.namespace) |> Enum.concat(extra) |> Enum.uniq()
      _ -> Enum.uniq(extra)
    end
  end

  defp reconcile_ns(host, channel, ns) do
    flintlock = list_flintlock(channel, ns)
    fl_by_uid = Map.new(flintlock, &{&1.spec.uid, &1})

    store_recs =
      case store().list_vms(ns) do
        {:ok, recs} -> Enum.filter(recs, &(&1.host_id == host.id and &1.state != :unknown))
        _ -> []
      end

    store_by_uid = Map.new(store_recs, &{&1.uid, &1})

    adopted = adopt_orphans(host, fl_by_uid, store_by_uid)
    lost = mark_lost(store_by_uid, fl_by_uid)
    synced = sync_states(store_by_uid, fl_by_uid)

    %{adopted: adopted, lost: lost, synced: synced}
  end

  defp adopt_orphans(host, fl_by_uid, store_by_uid) do
    for {uid, mv} <- fl_by_uid, not Map.has_key?(store_by_uid, uid), reduce: 0 do
      acc ->
        :ok = store().put_vm(adopt_record(host, mv))
        Logger.info("reconcile adopted orphan #{uid} on #{host.id}")
        acc + 1
    end
  end

  defp mark_lost(store_by_uid, fl_by_uid) do
    for {uid, rec} <- store_by_uid, not Map.has_key?(fl_by_uid, uid), reduce: 0 do
      acc ->
        :ok = store().put_vm(%{rec | state: :lost})
        Logger.warning("reconcile marked #{uid} lost (gone from flintlock)")
        acc + 1
    end
  end

  defp sync_states(store_by_uid, fl_by_uid) do
    for {uid, rec} <- store_by_uid, mv = fl_by_uid[uid], reduce: 0 do
      acc ->
        desired = record_state(mv)

        if rec.state != desired do
          :ok = store().put_vm(%{rec | state: desired})
          acc + 1
        else
          acc
        end
    end
  end

  # Remove :unknown placeholders in reconciled namespaces — they've been resolved
  # (adopted as an orphan, or the create truly failed).
  defp cleanup_unknowns(host, namespaces) do
    ns_set = MapSet.new(namespaces)

    case store().list_vms_on_host(host.id) do
      {:ok, vms} ->
        for vm <- vms, vm.state == :unknown, MapSet.member?(ns_set, vm.namespace) do
          store().delete_vm(vm.uid)
        end

      _ ->
        :ok
    end
  end

  defp list_flintlock(channel, ns) do
    case Brigade.LocalFlintlock.driver().list(channel, ns) do
      {:ok, %{microvm: vms}} -> vms
      _ -> []
    end
  end

  defp adopt_record(host, %Types.MicroVM{spec: s} = mv) do
    %VMRecord{
      uid: s.uid,
      namespace: s.namespace,
      name: s.id,
      host_id: host.id,
      vcpu: s.vcpu,
      memory_mb: s.memory_in_mb,
      provider: s.provider,
      labels: s.labels || %{},
      state: record_state(mv)
    }
  end

  defp record_state(%Types.MicroVM{status: %{state: :CREATED}}), do: :created
  defp record_state(%Types.MicroVM{status: %{state: :FAILED}}), do: :failed
  defp record_state(%Types.MicroVM{status: %{state: :PENDING}}), do: :creating
  defp record_state(_), do: :created

  defp empty_summary, do: %{adopted: 0, lost: 0, synced: 0}

  defp merge(a, b),
    do: %{adopted: a.adopted + b.adopted, lost: a.lost + b.lost, synced: a.synced + b.synced}

  defp store, do: Brigade.LocalFlintlock.store()
end
