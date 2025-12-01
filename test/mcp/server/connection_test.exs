defmodule MCP.Server.ConnectionTest do
  use ExUnit.Case, async: true

  alias MCP.Server.Connection
  alias MCP.Protocol.ErrorCodes

  defmodule TestHandler do
    use MCP.Server.Handler

    @impl true
    def server_info, do: %{name: "test-server", version: "1.0.0"}

    @impl true
    def capabilities, do: %{"tools" => %{}}

    @impl true
    def handle_request(%{method: "echo", params: params}) do
      {:ok, params}
    end

    def handle_request(%{method: method}) do
      {:error, ErrorCodes.method_not_found(), "Unknown method: #{method}"}
    end
  end

  setup do
    {:ok, conn} = Connection.start_link(handler: TestHandler)
    {:ok, conn: conn}
  end

  describe "connection lifecycle" do
    test "starts in uninitialized state", %{conn: conn} do
      assert Connection.get_state(conn) == :uninitialized
    end

    test "handles initialize request", %{conn: conn} do
      message = %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "method" => "initialize",
        "params" => %{
          "protocolVersion" => "2025-11-25",
          "capabilities" => %{},
          "clientInfo" => %{"name" => "test", "version" => "1.0"}
        }
      }

      {:ok, response} = Connection.handle_message(conn, message)

      assert response["jsonrpc"] == "2.0"
      assert response["id"] == 1
      assert response["result"]["protocolVersion"] == "2025-11-25"
      assert response["result"]["serverInfo"]["name"] == "test-server"
      assert response["result"]["capabilities"] == %{"tools" => %{}}
    end

    test "transitions to initializing after initialize request", %{conn: conn} do
      message = %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "method" => "initialize",
        "params" => %{
          "protocolVersion" => "2025-11-25",
          "capabilities" => %{},
          "clientInfo" => %{"name" => "test", "version" => "1.0"}
        }
      }

      Connection.handle_message(conn, message)
      assert Connection.get_state(conn) == :initializing
    end

    test "transitions to ready after initialized notification", %{conn: conn} do
      init_request = %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "method" => "initialize",
        "params" => %{
          "protocolVersion" => "2025-11-25",
          "capabilities" => %{},
          "clientInfo" => %{"name" => "test", "version" => "1.0"}
        }
      }

      initialized_notification = %{
        "jsonrpc" => "2.0",
        "method" => "notifications/initialized"
      }

      Connection.handle_message(conn, init_request)
      Connection.handle_message(conn, initialized_notification)

      assert Connection.get_state(conn) == :ready
    end
  end

  describe "ping handling" do
    test "responds to ping in any state", %{conn: conn} do
      message = %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "method" => "ping"
      }

      {:ok, response} = Connection.handle_message(conn, message)

      assert response["id"] == 1
      assert response["result"] == %{}
    end
  end

  describe "request handling" do
    test "rejects requests before initialization", %{conn: conn} do
      message = %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "method" => "echo",
        "params" => %{"test" => true}
      }

      {:ok, response} = Connection.handle_message(conn, message)

      assert response["error"]["code"] == ErrorCodes.invalid_request()
      assert response["error"]["message"] =~ "not initialized"
    end

    test "handles requests after initialization", %{conn: conn} do
      init_request = %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "method" => "initialize",
        "params" => %{
          "protocolVersion" => "2025-11-25",
          "capabilities" => %{},
          "clientInfo" => %{"name" => "test", "version" => "1.0"}
        }
      }

      initialized = %{
        "jsonrpc" => "2.0",
        "method" => "notifications/initialized"
      }

      echo_request = %{
        "jsonrpc" => "2.0",
        "id" => 2,
        "method" => "echo",
        "params" => %{"message" => "hello"}
      }

      Connection.handle_message(conn, init_request)
      Connection.handle_message(conn, initialized)
      {:ok, response} = Connection.handle_message(conn, echo_request)

      assert response["id"] == 2
      assert response["result"] == %{"message" => "hello"}
    end

    test "handles unknown method with error", %{conn: conn} do
      init_request = %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "method" => "initialize",
        "params" => %{
          "protocolVersion" => "2025-11-25",
          "capabilities" => %{},
          "clientInfo" => %{"name" => "test", "version" => "1.0"}
        }
      }

      initialized = %{
        "jsonrpc" => "2.0",
        "method" => "notifications/initialized"
      }

      unknown_request = %{
        "jsonrpc" => "2.0",
        "id" => 2,
        "method" => "unknown/method"
      }

      Connection.handle_message(conn, init_request)
      Connection.handle_message(conn, initialized)
      {:ok, response} = Connection.handle_message(conn, unknown_request)

      assert response["error"]["code"] == ErrorCodes.method_not_found()
    end
  end

  describe "notification handling" do
    test "returns nil for notifications", %{conn: conn} do
      notification = %{
        "jsonrpc" => "2.0",
        "method" => "some/notification"
      }

      {:ok, response} = Connection.handle_message(conn, notification)

      assert response == nil
    end
  end

  describe "error handling" do
    test "rejects double initialization", %{conn: conn} do
      init_request = %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "method" => "initialize",
        "params" => %{
          "protocolVersion" => "2025-11-25",
          "capabilities" => %{},
          "clientInfo" => %{"name" => "test", "version" => "1.0"}
        }
      }

      Connection.handle_message(conn, init_request)
      {:ok, response} = Connection.handle_message(conn, init_request)

      assert response["error"]["code"] == ErrorCodes.invalid_request()
      assert response["error"]["message"] =~ "Already initialized"
    end

    test "handles invalid request format", %{conn: conn} do
      invalid = %{"not" => "valid"}
      {:ok, response} = Connection.handle_message(conn, invalid)

      assert response["error"]["code"] == ErrorCodes.invalid_request()
    end
  end
end
