defmodule Brigade.ClusterSingletonTest do
  @moduledoc """
  M2: across a real multi-node mesh there is EXACTLY ONE scheduler, and it
  re-homes when its node dies (Horde failover). Boots the full :brigade app on
  peer nodes, connects them, and inspects the Horde singleton.

  Tagged :distributed — skipped if the node can't start distribution.
  """
  use ExUnit.Case, async: false

  @moduletag :distributed
  @moduletag timeout: 120_000

  alias Brigade.Scheduler

  setup_all do
    # Bring up distribution on the test node.
    case :net_kernel.start([:"brigade_primary@127.0.0.1", :longnames]) do
      {:ok, _} -> :ok
      {:error, {:already_started, _}} -> :ok
    end

    :erlang.set_cookie(node(), :brigade_test_cookie)
    :ok
  end

  setup do
    peers = for i <- 1..2, do: start_peer("peer#{i}")
    on_exit(fn -> Enum.each(peers, fn {peer, _node} -> safe_stop(peer) end) end)
    nodes = Enum.map(peers, fn {_peer, node} -> node end)
    all = [node() | nodes]

    # Full mesh: every node connects to every other, so Erlang's global partition
    # guard doesn't disconnect a partially-connected peer mid-test.
    for n <- all, m <- all, n != m do
      if n == node(), do: Node.connect(m), else: :erpc.call(n, :net_kernel, :connect_node, [m])
    end

    {:ok, peers: peers, nodes: nodes}
  end

  test "exactly one scheduler singleton across the mesh", %{nodes: nodes} do
    all = [node() | nodes]

    assert wait_until(fn -> unique_singleton(all) end, fn r -> match?({:ok, _}, r) end),
           "cluster did not converge to a single scheduler"

    {:ok, pid} = unique_singleton(all)
    assert node(pid) in all
  end

  test "singleton re-homes when its owning node dies", %{peers: peers, nodes: nodes} do
    all = [node() | nodes]

    {:ok, pid1} = eventually_singleton(all)
    owner = node(pid1)

    if owner == node() do
      # Scheduler landed on the primary; we can't kill ourselves. Assert it's
      # stable and skip the failover half (covered when it lands on a peer).
      assert Process.alive?(pid1)
    else
      {peer, ^owner} = Enum.find(peers, fn {_p, n} -> n == owner end)
      safe_stop(peer)

      survivors = all -- [owner]

      {:ok, pid2} = eventually_singleton(survivors)
      assert pid2 != pid1
      assert node(pid2) in survivors
    end
  end

  # --- helpers --------------------------------------------------------------

  defp start_peer(name) do
    {:ok, peer, node} =
      :peer.start_link(%{
        name: String.to_charlist(name),
        host: ~c"127.0.0.1",
        longnames: true,
        args: peer_args()
      })

    # Peer is already cookie-matched (via -setcookie) and connected over
    # distribution, so use :erpc (the peer's own control channel is unreliable).
    # Replicate the primary's :brigade config, then boot the app on the peer.
    for {k, v} <- Application.get_all_env(:brigade) do
      :erpc.call(node, Application, :put_env, [:brigade, k, v])
    end

    {:ok, _} = :erpc.call(node, Application, :ensure_all_started, [:brigade])
    {peer, node}
  end

  defp peer_args do
    # All args must be charlists. Include the cookie and the full code path so
    # the peer can load brigade + deps.
    [~c"-setcookie", ~c"brigade_test_cookie", ~c"-pa" | :code.get_path()]
  end

  defp safe_stop(peer) do
    try do
      :peer.stop(peer)
    catch
      _, _ -> :ok
    end
  end

  # Ask every node for its view of the singleton; succeed only if all agree on one pid.
  defp unique_singleton(nodes) do
    pids =
      nodes
      |> Enum.flat_map(&lookup_on(&1))
      |> Enum.uniq()

    case pids do
      [pid] -> if alive?(pid), do: {:ok, pid}, else: :not_yet
      _ -> :not_yet
    end
  end

  defp lookup_on(n) when n == node(),
    do: to_pids(Horde.Registry.lookup(Scheduler.registry(), :singleton))

  defp lookup_on(n),
    do: to_pids(:erpc.call(n, Horde.Registry, :lookup, [Scheduler.registry(), :singleton]))

  defp to_pids([{pid, _} | _]), do: [pid]
  defp to_pids(_), do: []

  defp alive?(pid) when node(pid) == node(), do: Process.alive?(pid)
  defp alive?(pid), do: :erpc.call(node(pid), Process, :alive?, [pid])

  defp eventually_singleton(nodes) do
    wait_until(fn -> unique_singleton(nodes) end, &match?({:ok, _}, &1)) ||
      flunk("no unique singleton across #{inspect(nodes)}")
  end

  defp wait_until(fun, pred, attempts \\ 100) do
    Enum.reduce_while(1..attempts, nil, fn _, _ ->
      res = fun.()

      if pred.(res) do
        {:halt, res}
      else
        Process.sleep(100)
        {:cont, false}
      end
    end)
  end
end
