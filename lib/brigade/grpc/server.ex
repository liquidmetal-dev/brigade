defmodule Brigade.GRPC.Server do
  @moduledoc """
  North edge: Brigade's own `MicroVM` gRPC service — the drop-in flintlock
  interface clients dial. It schedules and forwards:

    * `CreateMicroVM` — reserve capacity via the scheduler, forward to the chosen
      host's flintlock (blocking), confirm/release the reservation, return
      flintlock's response (pass-through uid).
    * `GetMicroVM` / `DeleteMicroVM` — look up `uid -> host` in the store, forward
      to that host's flintlock.
    * `ListMicroVMs[Stream]` — answered from Brigade's own state store (the
      placement source of truth), not a host fan-out.
  """
  use GRPC.Server, service: Microvm.Services.Api.V1alpha1.MicroVM.Service
  require Logger

  alias Microvm.Services.Api.V1alpha1, as: Api
  alias Flintlock.Types
  alias Brigade.{Scheduler, VMRecord}

  # --- Create ---------------------------------------------------------------

  def create_micro_vm(%Api.CreateMicroVMRequest{microvm: nil}, _stream) do
    raise GRPC.RPCError, status: :invalid_argument, message: "microvm spec required"
  end

  def create_micro_vm(%Api.CreateMicroVMRequest{microvm: spec} = req, _stream) do
    demand = Scheduler.demand_from_spec(spec)

    case Scheduler.reserve(demand, scheduler()) do
      {:ok, %{host: host, ref: ref}} ->
        forward_create(host, ref, spec, req)

      {:error, :no_capacity} ->
        raise GRPC.RPCError,
          status: :resource_exhausted,
          message: "no host has capacity for #{spec.vcpu} vcpu / #{spec.memory_in_mb} MB"

      {:error, :no_hosts} ->
        raise GRPC.RPCError, status: :unavailable, message: "no schedulable hosts"
    end
  end

  defp forward_create(host, ref, spec, req) do
    {:ok, channel} = driver().connect(host)

    try do
      case driver().create(channel, req) do
        {:ok, %Api.CreateMicroVMResponse{microvm: mv} = resp} ->
          :ok = Scheduler.confirm(ref, record(mv, host, spec), scheduler())
          resp

        {:error, %GRPC.RPCError{} = err} ->
          Scheduler.release(ref, scheduler())
          raise err

        {:error, reason} ->
          Scheduler.release(ref, scheduler())
          Logger.error("flintlock create failed on #{host.id}: #{inspect(reason)}")
          raise GRPC.RPCError, status: :internal, message: "host create failed"
      end
    after
      GRPC.Stub.disconnect(channel)
    end
  end

  defp record(%Types.MicroVM{spec: mvspec} = _mv, host, req_spec) do
    %VMRecord{
      uid: mvspec.uid,
      namespace: req_spec.namespace,
      name: mvspec.id,
      host_id: host.id,
      vcpu: req_spec.vcpu,
      memory_mb: req_spec.memory_in_mb,
      provider: req_spec.provider,
      labels: req_spec.labels || %{},
      state: :created
    }
  end

  # --- Get ------------------------------------------------------------------

  def get_micro_vm(%Api.GetMicroVMRequest{uid: uid}, _stream) do
    with {:ok, rec} <- store().get_vm(uid),
         {:ok, host} <- store().get_host(rec.host_id),
         {:ok, channel} <- driver().connect(host) do
      try do
        case driver().get(channel, uid) do
          {:ok, %Api.GetMicroVMResponse{} = resp} -> resp
          {:error, %GRPC.RPCError{} = err} -> raise err
          {:error, _} -> raise GRPC.RPCError, status: :internal, message: "host get failed"
        end
      after
        GRPC.Stub.disconnect(channel)
      end
    else
      {:error, :not_found} ->
        raise GRPC.RPCError, status: :not_found, message: "microvm #{uid} not found"
    end
  end

  # --- Delete ---------------------------------------------------------------

  def delete_micro_vm(%Api.DeleteMicroVMRequest{uid: uid}, _stream) do
    case store().get_vm(uid) do
      {:ok, rec} ->
        {:ok, host} = store().get_host(rec.host_id)
        {:ok, channel} = driver().connect(host)

        try do
          _ = driver().delete(channel, uid)
        after
          GRPC.Stub.disconnect(channel)
        end

        # Removing the record frees the host's committed capacity for future placement.
        :ok = store().delete_vm(uid)
        %Google.Protobuf.Empty{}

      {:error, :not_found} ->
        # Idempotent delete — flintlock's DeleteMicroVM returns Empty for unknown uids too.
        %Google.Protobuf.Empty{}
    end
  end

  # --- List (from Brigade's state store) ------------------------------------

  def list_micro_v_ms(%Api.ListMicroVMsRequest{namespace: ns, name: name}, _stream) do
    {:ok, recs} = store().list_vms(ns, blank_to_nil(name))
    %Api.ListMicroVMsResponse{microvm: Enum.map(recs, &to_microvm/1)}
  end

  def list_micro_v_ms_stream(%Api.ListMicroVMsRequest{namespace: ns, name: name}, stream) do
    {:ok, recs} = store().list_vms(ns, blank_to_nil(name))

    Enum.each(recs, fn rec ->
      GRPC.Server.send_reply(stream, %Api.ListMessage{microvm: to_microvm(rec)})
    end)
  end

  # Synthesize a flintlock MicroVM proto from Brigade's record for List responses.
  defp to_microvm(%VMRecord{} = rec) do
    %Types.MicroVM{
      version: 1,
      spec: %Types.MicroVMSpec{
        id: rec.name,
        namespace: rec.namespace,
        uid: rec.uid,
        vcpu: rec.vcpu,
        memory_in_mb: rec.memory_mb,
        provider: rec.provider,
        labels: rec.labels
      },
      status: %Types.MicroVMStatus{state: state_enum(rec.state)}
    }
  end

  defp state_enum(:created), do: :CREATED
  defp state_enum(:failed), do: :FAILED
  defp state_enum(state) when state in [:reserved, :creating], do: :PENDING
  defp state_enum(_), do: :FAILED

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(name), do: name

  # --- config seams ---------------------------------------------------------

  defp driver, do: Application.get_env(:brigade, :host_driver, Brigade.HostDriver.Local)
  defp store, do: Application.get_env(:brigade, :store, Brigade.Store.Mnesia)
  # Resolves to the Horde cluster-singleton scheduler.
  defp scheduler, do: Application.get_env(:brigade, :scheduler, Brigade.Scheduler.via())
end
