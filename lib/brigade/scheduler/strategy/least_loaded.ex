defmodule Brigade.Scheduler.Strategy.LeastLoaded do
  @moduledoc """
  Default placement strategy: spread. Filter to hosts that fit the demand and
  satisfy its constraints, then pick the host with the highest free ratio — the
  emptiest host wins, minimising blast radius when a host dies (aligns with the
  no-auto-reschedule policy).
  """
  @behaviour Brigade.Scheduler.Strategy

  alias Brigade.Host

  @impl true
  def filter(candidates, demand) do
    Enum.filter(candidates, fn {host, free} ->
      host.status == :available and
        free.vcpu >= demand.vcpu and
        free.memory_mb >= demand.memory_mb and
        provider_ok?(host, demand.provider) and
        constraints_ok?(host, demand.constraints)
    end)
  end

  @impl true
  def score([], _demand), do: :none

  def score(candidates, _demand) do
    {host, _free} = Enum.max_by(candidates, fn {host, free} -> free_ratio(host, free) end)
    {:ok, host}
  end

  # Empty provider list on a host means "accepts any provider".
  defp provider_ok?(_host, nil), do: true
  defp provider_ok?(%Host{providers: []}, _p), do: true
  defp provider_ok?(%Host{providers: ps}, p), do: p in ps

  # Every requested constraint must match a host label of the same (unprefixed) key.
  defp constraints_ok?(%Host{labels: labels}, constraints) do
    Enum.all?(constraints, fn {k, v} -> Map.get(labels, k) == v end)
  end

  # Bottleneck ratio across vcpu and memory; higher = emptier.
  defp free_ratio(%Host{capacity: cap}, free) do
    min(ratio(free.vcpu, cap.vcpu), ratio(free.memory_mb, cap.memory_mb))
  end

  defp ratio(_free, 0), do: 0.0
  defp ratio(free, total), do: free / total
end
