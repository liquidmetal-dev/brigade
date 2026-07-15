defmodule Brigade.HostRegistry do
  @moduledoc """
  Membership seam: how a host joins the pool and announces its declared
  capacity + labels, and how the two liveness signals combine.

  Day-1 (topology A) `Brigade.HostRegistry.SelfRegister` registers the local
  node on boot / `nodeup` from config, and marks it `:unreachable` on
  `nodedown`. A future static-config / API provider (for topology B, where hosts
  are not Erlang nodes) can feed the same registry.

  **Dual liveness**: a host is `:available` (schedulable) only when BOTH the
  Erlang node is up AND its local flintlockd health check is green. Either
  signal going red flips the host out of the schedulable set.
  """

  @doc "Register (or refresh) a host in the pool."
  @callback register(Brigade.Host.t()) :: :ok | {:error, term()}

  @doc "Mark a host's status (e.g. `:unreachable` on nodedown, `:available` when both signals green)."
  @callback set_status(host_id :: String.t(), Brigade.Host.status()) :: :ok | {:error, term()}

  @doc "List hosts currently eligible for placement (dual-liveness green, in quorum)."
  @callback schedulable_hosts() :: {:ok, [Brigade.Host.t()]} | {:error, term()}
end
