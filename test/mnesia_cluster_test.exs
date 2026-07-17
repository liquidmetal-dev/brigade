defmodule Brigade.MnesiaClusterTest do
  @moduledoc """
  Issue 13: the Mnesia host/VM tables must be genuinely replicated across the
  mesh, not node-local. Boots the full :brigade app on a peer node, connects the
  mesh, and asserts that records written on one node are visible on the other —
  in both directions and for both tables — and that hosts registered on
  different nodes aggregate into one view.

  Tagged :distributed — skipped unless run with `--include distributed`.
  """
  use ExUnit.Case, async: false

  @moduletag :distributed
  @moduletag timeout: 120_000

  alias Brigade.{Host, VMRecord}
  alias Brigade.Store.Mnesia

  setup_all do
    case :net_kernel.start([:"brigade_primary@127.0.0.1", :longnames]) do
      {:ok, _} -> :ok
      {:error, {:already_started, _}} -> :ok
    end

    :erlang.set_cookie(node(), :brigade_test_cookie)
    :ok
  end

  setup do
    {peer, peer_node} = start_peer("mnesiapeer1")
    on_exit(fn -> safe_stop(peer) end)

    # Full mesh, then let the store's nodeup handler join Mnesia. Start from a
    # clean, mesh-joined table so tests don't leak records into each other
    # (the tables are replicated, so clearing on the primary clears the mesh).
    Node.connect(peer_node)
    :ok = await_replica(peer_node)
    {:atomic, :ok} = :mnesia.clear_table(:brigade_vms)
    {:atomic, :ok} = :mnesia.clear_table(:brigade_hosts)

    {:ok, peer: peer, peer_node: peer_node}
  end

  test "records replicate across the mesh in both directions", %{peer_node: peer} do
    # Write on the primary, read on the peer.
    host_a = %Host{id: "host-A", node: node(), endpoint: "a:9090", capacity: res(4, 4096)}
    vm_a = %VMRecord{uid: "vm-A", namespace: "ns", host_id: "host-A", state: :created}
    :ok = Mnesia.put_host(host_a)
    :ok = Mnesia.put_vm(vm_a)

    assert wait_until(
             fn -> :erpc.call(peer, Mnesia, :get_host, ["host-A"]) end,
             &match?({:ok, _}, &1)
           ),
           "host written on primary never became visible on the peer"

    assert wait_until(
             fn -> :erpc.call(peer, Mnesia, :get_vm, ["vm-A"]) end,
             &match?({:ok, _}, &1)
           ),
           "vm written on primary never became visible on the peer"

    # Write on the peer, read on the primary (proves symmetric local replicas).
    host_b = %Host{id: "host-B", node: peer, endpoint: "b:9090", capacity: res(4, 4096)}
    vm_b = %VMRecord{uid: "vm-B", namespace: "ns", host_id: "host-B", state: :created}
    :ok = :erpc.call(peer, Mnesia, :put_host, [host_b])
    :ok = :erpc.call(peer, Mnesia, :put_vm, [vm_b])

    assert wait_until(fn -> Mnesia.get_host("host-B") end, &match?({:ok, _}, &1)),
           "host written on peer never became visible on the primary"

    assert wait_until(fn -> Mnesia.get_vm("vm-B") end, &match?({:ok, _}, &1)),
           "vm written on peer never became visible on the primary"
  end

  test "each node holds a local ram_copies replica, not just a merged schema", %{peer_node: peer} do
    assert wait_until(
             fn -> :erpc.call(peer, :mnesia, :table_info, [:brigade_vms, :ram_copies]) end,
             fn nodes -> peer in nodes and node() in nodes end
           ),
           "brigade_vms is not a local ram_copies replica on both nodes"
  end

  test "hosts registered on different nodes aggregate into one view", %{peer_node: peer} do
    # Each node registers its own host (as self-register does on boot); the
    # scheduler must see both from either node.
    :ok =
      Mnesia.put_host(%Host{
        id: "host-primary",
        node: node(),
        endpoint: "p:9090",
        capacity: res(4, 4096)
      })

    :ok =
      :erpc.call(peer, Mnesia, :put_host, [
        %Host{id: "host-peer", node: peer, endpoint: "q:9090", capacity: res(4, 4096)}
      ])

    assert wait_until(
             fn -> Mnesia.list_hosts() end,
             fn
               {:ok, hosts} ->
                 MapSet.new(hosts, & &1.id) == MapSet.new(["host-primary", "host-peer"])

               _ ->
                 false
             end
           ),
           "hosts from both nodes did not aggregate into a single view"
  end

  # --- helpers --------------------------------------------------------------

  defp res(vcpu, memory_mb), do: %{vcpu: vcpu, memory_mb: memory_mb}

  # Block until the peer has joined the mesh store and holds a local replica.
  defp await_replica(peer) do
    ok? =
      wait_until(
        fn -> :erpc.call(peer, :mnesia, :table_info, [:brigade_hosts, :ram_copies]) end,
        fn nodes -> is_list(nodes) and peer in nodes and node() in nodes end
      )

    if ok?, do: :ok, else: flunk("peer #{peer} never joined the mesh store")
  end

  defp start_peer(name) do
    {:ok, peer, node} =
      :peer.start_link(%{
        name: String.to_charlist(name),
        host: ~c"127.0.0.1",
        longnames: true,
        args: peer_args()
      })

    for {k, v} <- Application.get_all_env(:brigade) do
      :erpc.call(node, Application, :put_env, [:brigade, k, v])
    end

    {:ok, _} = :erpc.call(node, Application, :ensure_all_started, [:brigade])
    {peer, node}
  end

  defp peer_args do
    [~c"-setcookie", ~c"brigade_test_cookie", ~c"-pa" | :code.get_path()]
  end

  defp safe_stop(peer) do
    try do
      :peer.stop(peer)
    catch
      _, _ -> :ok
    end
  end

  defp wait_until(fun, pred, attempts \\ 100) do
    Enum.reduce_while(1..attempts, false, fn _, _ ->
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
