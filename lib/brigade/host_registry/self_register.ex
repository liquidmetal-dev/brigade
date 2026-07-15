defmodule Brigade.HostRegistry.SelfRegister do
  @moduledoc """
  Day-1 (topology A) host registration: on boot, the local node reads its
  declared capacity/labels from config and registers itself into the store's
  host inventory, pointing at its local flintlockd endpoint.

  M1 marks the host `:available` on registration. Full dual-liveness (Erlang
  `nodedown` + local flintlock health gating) lands in M3; nodeup-driven
  re-registration and the shared registry provider (for topology B) follow.
  """
  @behaviour Brigade.HostRegistry
  use GenServer
  require Logger

  alias Brigade.Host

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl GenServer
  def init(opts) do
    host = build_host(opts)
    :ok = register(host)
    Logger.info("registered host #{host.id} (#{host.endpoint}) cap=#{inspect(host.capacity)}")
    {:ok, %{host_id: host.id}}
  end

  @impl Brigade.HostRegistry
  def register(%Host{} = host), do: store().put_host(host)

  @impl Brigade.HostRegistry
  def set_status(host_id, status) do
    case store().get_host(host_id) do
      {:ok, host} -> store().put_host(%{host | status: status})
      err -> err
    end
  end

  @impl Brigade.HostRegistry
  def schedulable_hosts do
    case store().list_hosts() do
      {:ok, hosts} -> {:ok, Enum.filter(hosts, &(&1.status == :available))}
      err -> err
    end
  end

  defp build_host(opts) do
    cfg = Keyword.merge(Application.get_env(:brigade, :host, []), opts)
    id = Keyword.get(cfg, :id, to_string(node()))

    endpoint =
      Keyword.get(
        cfg,
        :endpoint,
        Application.get_env(:brigade, :flintlock_endpoint, "localhost:9090")
      )

    %Host{
      id: id,
      node: node(),
      endpoint: endpoint,
      labels: Keyword.get(cfg, :labels, %{}),
      capacity: to_res(Keyword.get(cfg, :capacity, [])),
      reserve: to_res(Keyword.get(cfg, :reserve, [])),
      providers: Keyword.get(cfg, :providers, []),
      status: :available,
      auth_token: Application.get_env(:brigade, :flintlock_auth_token),
      tls: Application.get_env(:brigade, :flintlock_tls)
    }
  end

  defp to_res(kw),
    do: %{vcpu: Keyword.get(kw, :vcpu, 0), memory_mb: Keyword.get(kw, :memory_mb, 0)}

  defp store, do: Application.get_env(:brigade, :store, Brigade.Store.Mnesia)
end
