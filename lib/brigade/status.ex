defmodule Brigade.Status do
  @moduledoc """
  Point-in-time view of the cluster for humans and gauges: mesh membership,
  partition/quorum state, where the singleton scheduler lives, and per-host
  capacity (declared, reserved, committed, free) + VM counts.

  Pure read over the store + cluster; safe to call from any node/partition.
  """

  alias Brigade.Host

  @committed_states [:reserved, :creating, :created]

  @type host_view :: %{
          id: String.t(),
          node: node() | nil,
          status: Host.status(),
          labels: map(),
          capacity: Host.resources(),
          schedulable: Host.resources(),
          committed: Host.resources(),
          free: Host.resources(),
          vm_count: non_neg_integer()
        }

  @spec snapshot() :: map()
  def snapshot do
    members = [Node.self() | Node.list()]

    %{
      node: Node.self(),
      scheduler_node: scheduler_node(),
      flintlock_api_version: Application.get_env(:brigade, :flintlock_api_version),
      partition: %{
        size: length(members),
        members: members,
        min_cluster_size: min_cluster_size(),
        in_quorum: length(members) >= min_cluster_size()
      },
      hosts: host_views(),
      schedulable_hosts: Enum.count(host_views(), &(&1.status == :available))
    }
  end

  @spec host_views() :: [host_view()]
  def host_views do
    case store().list_hosts() do
      {:ok, hosts} -> Enum.map(hosts, &host_view/1)
      _ -> []
    end
  end

  defp host_view(%Host{} = host) do
    sched = Host.schedulable(host)
    {committed, vm_count} = committed(host)

    %{
      id: host.id,
      node: host.node,
      status: host.status,
      labels: host.labels,
      capacity: host.capacity,
      schedulable: sched,
      committed: committed,
      free: %{
        vcpu: sched.vcpu - committed.vcpu,
        memory_mb: sched.memory_mb - committed.memory_mb
      },
      vm_count: vm_count
    }
  end

  defp committed(%Host{id: id}) do
    case store().list_vms_on_host(id) do
      {:ok, vms} ->
        active = Enum.filter(vms, &(&1.state in @committed_states))

        res =
          Enum.reduce(active, %{vcpu: 0, memory_mb: 0}, fn vm, acc ->
            %{vcpu: acc.vcpu + vm.vcpu, memory_mb: acc.memory_mb + vm.memory_mb}
          end)

        {res, length(active)}

      _ ->
        {%{vcpu: 0, memory_mb: 0}, 0}
    end
  end

  defp scheduler_node do
    case Horde.Registry.lookup(Brigade.Scheduler.registry(), :singleton) do
      [{pid, _}] -> node(pid)
      _ -> nil
    end
  end

  defp min_cluster_size, do: Application.get_env(:brigade, :min_cluster_size, 1)
  defp store, do: Application.get_env(:brigade, :store, Brigade.Store.Mnesia)
end
