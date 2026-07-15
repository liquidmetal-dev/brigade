defmodule Brigade.Store.Mnesia.Setup do
  @moduledoc """
  One-shot supervision-tree worker that ensures Mnesia tables exist before
  anything that reads/writes state starts. Runs `Brigade.Store.Mnesia.setup!/0`
  on init, then idles (kept alive so the supervisor treats setup as a dependency
  that stays up).
  """
  use GenServer

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(_opts) do
    :ok = Brigade.Store.Mnesia.setup!()
    {:ok, %{}}
  end
end
