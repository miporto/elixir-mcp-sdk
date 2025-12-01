defmodule Examples.HelloWorld.Server do
  @moduledoc """
  A basic HTTP server example using Bandit and Plug.

  This example demonstrates:
  - Setting up a Plug router
  - Basic HTTP endpoints
  - Running a server with Bandit
  """

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/hello" do
    send_resp(conn, 200, "Hello from MCP SDK Example!")
  end

  get "/health" do
    send_resp(conn, 200, "OK")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
