defmodule Brigade.Store do
  @moduledoc """
  Persistence seam for Brigade's authoritative state: the `uid -> host` map,
  host inventory, capacity reservations, and per-VM records.

  Day-1 implementation is Mnesia (`Brigade.Store.Mnesia`), riding the distributed
  Erlang mesh with no external dependency. The behaviour exists so a Postgres
  (or other) backend can be swapped in for the future central-control-plane
  topology (B) without touching the scheduler or gRPC layers.

  All records key VMs by the flintlock-assigned `uid` (pass-through identity).
  """

  alias Brigade.{Host, VMRecord}

  # --- VM records -----------------------------------------------------------

  @doc "Insert or update a VM record, keyed by its flintlock uid."
  @callback put_vm(VMRecord.t()) :: :ok | {:error, term()}

  @doc "Fetch a VM record by uid."
  @callback get_vm(uid :: String.t()) :: {:ok, VMRecord.t()} | {:error, :not_found}

  @doc "Delete a VM record by uid."
  @callback delete_vm(uid :: String.t()) :: :ok | {:error, term()}

  @doc "List VM records in a namespace (optionally filtered by name)."
  @callback list_vms(namespace :: String.t(), name :: String.t() | nil) ::
              {:ok, [VMRecord.t()]} | {:error, term()}

  @doc "List every VM record known to live on a given host."
  @callback list_vms_on_host(host :: String.t()) :: {:ok, [VMRecord.t()]} | {:error, term()}

  # --- Host inventory -------------------------------------------------------

  @doc "Insert or update a host inventory record."
  @callback put_host(Host.t()) :: :ok | {:error, term()}

  @doc "Fetch a host by its id (Erlang node name day 1)."
  @callback get_host(host_id :: String.t()) :: {:ok, Host.t()} | {:error, :not_found}

  @doc "List all known hosts."
  @callback list_hosts() :: {:ok, [Host.t()]} | {:error, term()}
end
