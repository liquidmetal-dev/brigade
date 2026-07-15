defmodule Brigade.Status.Router do
  @moduledoc """
  Minimal HTTP status surface for operators (served by Bandit):

    * `GET /healthz` — liveness; 200 when in quorum, 503 otherwise
    * `GET /status`  — JSON cluster view (`Brigade.Status.snapshot/0`)
  """
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/healthz" do
    snap = Brigade.Status.snapshot()
    code = if snap.partition.in_quorum, do: 200, else: 503
    send_json(conn, code, %{ok: snap.partition.in_quorum, node: snap.node})
  end

  get "/status" do
    send_json(conn, 200, Brigade.Status.snapshot())
  end

  match _ do
    send_json(conn, 404, %{error: "not found"})
  end

  defp send_json(conn, code, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, Jason.encode!(body))
  end
end
