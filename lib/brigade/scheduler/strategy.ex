defmodule Brigade.Scheduler.Strategy do
  @moduledoc """
  Placement policy seam: Kubernetes-style filter -> score.

  Day-1 implementation is `Brigade.Scheduler.Strategy.LeastLoaded` (spread —
  pick the host with the highest free ratio, to minimise blast radius on host
  death). Alternative strategies (bin-pack for consolidation, affinity-weighted)
  can be added without touching the singleton scheduler.

  A `demand` is the resource + constraint ask derived from a `CreateMicroVM`
  request: required vcpu/memory, provider, and any `brigade.scheduling/*`
  label constraints. `free` is per-host schedulable capacity minus summed
  reservations, supplied by the scheduler from `Brigade.Store`.
  """

  @type demand :: %{
          vcpu: non_neg_integer(),
          memory_mb: non_neg_integer(),
          provider: String.t() | nil,
          constraints: %{optional(String.t()) => String.t()}
        }

  @type free :: %{vcpu: non_neg_integer(), memory_mb: non_neg_integer()}

  @typedoc "A candidate host paired with its currently free schedulable capacity."
  @type candidate :: {Brigade.Host.t(), free()}

  @doc """
  Drop candidates that cannot host the demand: not `:available`, insufficient
  free vcpu/memory, unmet label constraints, or unsupported provider.
  """
  @callback filter([candidate()], demand()) :: [candidate()]

  @doc """
  Rank the surviving candidates and return the chosen host, or `:none` if the
  list is empty. Higher score wins.
  """
  @callback score([candidate()], demand()) :: {:ok, Brigade.Host.t()} | :none
end
