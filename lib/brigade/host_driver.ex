defmodule Brigade.HostDriver do
  @moduledoc """
  Transport seam to a single host's `flintlockd`.

  Day-1 (topology A) `Brigade.HostDriver.Local` dials `localhost:9090` on the
  co-located node — no auth/TLS surface. The behaviour exists so a `Remote`
  driver (network dial + basic-auth token + mTLS) can be dropped in for the
  future central-control-plane topology (B) without touching the scheduler.

  Every callback mirrors a flintlock `MicroVM` RPC. Implementations use the
  generated `Microvm.Services.Api.V1alpha1.MicroVM.Stub`.
  """

  alias Microvm.Services.Api.V1alpha1, as: Api

  @typedoc "Opaque per-host connection handle (e.g. a GRPC.Channel)."
  @type conn :: term()

  @doc "Open a connection to the given host."
  @callback connect(Brigade.Host.t()) :: {:ok, conn()} | {:error, term()}

  @doc "Forward a CreateMicroVM to the host's flintlock."
  @callback create(conn(), Api.CreateMicroVMRequest.t()) ::
              {:ok, Api.CreateMicroVMResponse.t()} | {:error, term()}

  @doc "Fetch a microVM by uid from the host's flintlock."
  @callback get(conn(), uid :: String.t()) ::
              {:ok, Api.GetMicroVMResponse.t()} | {:error, term()}

  @doc "Delete a microVM by uid on the host's flintlock."
  @callback delete(conn(), uid :: String.t()) :: :ok | {:error, term()}

  @doc "List microVMs in a namespace on the host's flintlock (reconcile path)."
  @callback list(conn(), namespace :: String.t()) ::
              {:ok, Api.ListMicroVMsResponse.t()} | {:error, term()}
end
