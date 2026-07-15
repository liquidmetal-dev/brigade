defmodule Brigade.AuthTest do
  @moduledoc """
  M4 auth on both edges (mirrors flintlock basic-auth):
    * north — clients must present `Bearer <token>` when :auth_token is set
    * south — Brigade presents the host's token to that host's flintlock
  """
  use ExUnit.Case, async: false

  alias Microvm.Services.Api.V1alpha1, as: Api
  alias Flintlock.Types
  alias Brigade.{Host, Store.Mnesia}

  @north_port 59_096
  @fake_port 59_097

  setup do
    :mnesia.clear_table(:brigade_vms)
    :mnesia.clear_table(:brigade_hosts)
    {:ok, _, _} = GRPC.Server.start_endpoint(Brigade.GRPC.Endpoint, @north_port)
    on_exit(fn -> GRPC.Server.stop_endpoint(Brigade.GRPC.Endpoint) end)
    :ok
  end

  defp put_env(key, val) do
    Application.put_env(:brigade, key, val)
    on_exit(fn -> Application.delete_env(:brigade, key) end)
  end

  describe "north edge" do
    setup do
      put_env(:auth_token, "sekret")
      :ok
    end

    test "rejects a request with no token" do
      {:ok, ch} = GRPC.Stub.connect("localhost:#{@north_port}")
      on_exit(fn -> GRPC.Stub.disconnect(ch) end)

      assert {:error, %GRPC.RPCError{status: 16}} =
               Api.MicroVM.Stub.get_micro_vm(ch, %Api.GetMicroVMRequest{uid: "x"})
    end

    test "rejects a wrong token" do
      {:ok, ch} =
        GRPC.Stub.connect("localhost:#{@north_port}", headers: [{"authorization", "Bearer nope"}])

      on_exit(fn -> GRPC.Stub.disconnect(ch) end)

      assert {:error, %GRPC.RPCError{status: 16}} =
               Api.MicroVM.Stub.get_micro_vm(ch, %Api.GetMicroVMRequest{uid: "x"})
    end

    test "accepts the correct token (auth passes; handler runs)" do
      {:ok, ch} =
        GRPC.Stub.connect("localhost:#{@north_port}",
          headers: [{"authorization", "Bearer sekret"}]
        )

      on_exit(fn -> GRPC.Stub.disconnect(ch) end)

      # not_found (5) means we got past auth into the handler.
      assert {:error, %GRPC.RPCError{status: 5}} =
               Api.MicroVM.Stub.get_micro_vm(ch, %Api.GetMicroVMRequest{uid: "x"})
    end
  end

  describe "south edge" do
    setup do
      start_supervised!(FakeFlintlock.store_child_spec())
      {:ok, _, _} = FakeFlintlock.start_endpoint(@fake_port)
      on_exit(&FakeFlintlock.stop_endpoint/0)
      FakeFlintlock.reset()
      put_env(:fake_flintlock_token, "flsecret")
      :ok
    end

    defp host(token) do
      %Host{
        id: "h",
        node: node(),
        endpoint: "localhost:#{@fake_port}",
        capacity: %{vcpu: 8, memory_mb: 8192},
        reserve: %{vcpu: 0, memory_mb: 0},
        status: :available,
        auth_token: token
      }
    end

    defp create(ch),
      do:
        Api.MicroVM.Stub.create_micro_vm(ch, %Api.CreateMicroVMRequest{
          microvm: %Types.MicroVMSpec{id: "v", namespace: "ns", vcpu: 1, memory_in_mb: 1}
        })

    test "Brigade presents the host token to flintlock (accepted)" do
      :ok = Mnesia.put_host(host("flsecret"))
      {:ok, ch} = GRPC.Stub.connect("localhost:#{@north_port}")
      on_exit(fn -> GRPC.Stub.disconnect(ch) end)

      assert {:ok, %Api.CreateMicroVMResponse{}} = create(ch)
      assert FakeFlintlock.count() == 1
    end

    test "missing host token is rejected by flintlock" do
      :ok = Mnesia.put_host(host(nil))
      {:ok, ch} = GRPC.Stub.connect("localhost:#{@north_port}")
      on_exit(fn -> GRPC.Stub.disconnect(ch) end)

      assert {:error, %GRPC.RPCError{status: 16}} = create(ch)
      assert FakeFlintlock.count() == 0
    end
  end
end
