defmodule Brigade.VMRecord do
  @moduledoc """
  Brigade's record of a microVM it placed: the mapping from flintlock `uid` to
  the host running it, plus the placement lifecycle state and enough of the spec
  to answer `Get`/`List` locally and to recompute host capacity.

  `uid` is flintlock's assigned identifier (pass-through). It is wrapped here so
  a Brigade-owned uid can be introduced later (for live migration) without
  changing callers — `uid` stays the external handle, an internal field can
  diverge from it.

  Lifecycle (`state`):

    * `:reserved`    — scheduler debited capacity, create not yet forwarded
    * `:creating`    — `CreateMicroVM` in flight to the host's flintlock
    * `:created`     — flintlock returned; VM live, reservation confirmed
    * `:failed`      — flintlock errored; reservation released
    * `:unknown`     — forward RPC ambiguous (timeout); awaiting reconcile
    * `:unreachable` — host went down; last-known state, capacity released
    * `:lost`        — reconcile confirmed the VM no longer exists on the host
  """

  @type state ::
          :reserved | :creating | :created | :failed | :unknown | :unreachable | :lost

  @type t :: %__MODULE__{
          uid: String.t(),
          namespace: String.t(),
          name: String.t(),
          host_id: String.t(),
          vcpu: non_neg_integer(),
          memory_mb: non_neg_integer(),
          provider: String.t() | nil,
          labels: %{optional(String.t()) => String.t()},
          state: state()
        }

  @enforce_keys [:uid, :namespace, :host_id]
  defstruct uid: nil,
            namespace: nil,
            name: nil,
            host_id: nil,
            vcpu: 0,
            memory_mb: 0,
            provider: nil,
            labels: %{},
            state: :reserved
end
