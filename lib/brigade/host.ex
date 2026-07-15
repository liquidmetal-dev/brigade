defmodule Brigade.Host do
  @moduledoc """
  A schedulable flintlock host in the Brigade pool.

  Day-1 (topology A) a host is co-located with a Brigade node, so `id` is the
  Erlang node name and `endpoint` is `localhost:9090`. Capacity is
  **statically declared** (flintlock exposes no capacity API); `reserve` is
  headroom held back for the host OS + BEAM + flintlockd itself. Schedulable
  capacity is `capacity - reserve`, and free capacity subtracts summed
  reservations of placed VMs (tracked in `Brigade.Store`, not here).

  `status` combines the two liveness signals (Erlang `nodedown` + local
  flintlock health); only `:available` hosts are eligible for placement.
  """

  @type status :: :available | :unreachable | :draining
  @type resources :: %{vcpu: non_neg_integer(), memory_mb: non_neg_integer()}

  @type t :: %__MODULE__{
          id: String.t(),
          node: node() | nil,
          endpoint: String.t(),
          labels: %{optional(String.t()) => String.t()},
          capacity: resources(),
          reserve: resources(),
          providers: [String.t()],
          status: status()
        }

  @enforce_keys [:id, :endpoint, :capacity]
  defstruct id: nil,
            node: nil,
            endpoint: "localhost:9090",
            labels: %{},
            capacity: %{vcpu: 0, memory_mb: 0},
            reserve: %{vcpu: 0, memory_mb: 0},
            providers: [],
            status: :unreachable

  @doc "Schedulable capacity = declared total minus OS/BEAM reserve headroom."
  @spec schedulable(t()) :: resources()
  def schedulable(%__MODULE__{capacity: cap, reserve: res}) do
    %{
      vcpu: max(cap.vcpu - res.vcpu, 0),
      memory_mb: max(cap.memory_mb - res.memory_mb, 0)
    }
  end
end
