defmodule MCP.Protocol.LifecycleTest do
  use ExUnit.Case, async: true

  alias MCP.Protocol.{Lifecycle, Request, Response, Notification}

  describe "protocol_version/0" do
    test "returns the protocol version" do
      assert Lifecycle.protocol_version() == "2025-11-25"
    end
  end

  describe "initialize_request/3" do
    test "creates an initialize request" do
      client_info = %{name: "test-client", version: "1.0.0"}
      capabilities = %{"roots" => %{}}

      request = Lifecycle.initialize_request(1, client_info, capabilities)

      assert %Request{} = request
      assert request.id == 1
      assert request.method == "initialize"
      assert request.params["protocolVersion"] == "2025-11-25"
      assert request.params["clientInfo"]["name"] == "test-client"
      assert request.params["clientInfo"]["version"] == "1.0.0"
      assert request.params["capabilities"] == %{"roots" => %{}}
    end

    test "uses empty capabilities by default" do
      client_info = %{name: "test", version: "1.0"}
      request = Lifecycle.initialize_request(1, client_info)

      assert request.params["capabilities"] == %{}
    end
  end

  describe "initialize_response/3" do
    test "creates an initialize response" do
      server_info = %{name: "test-server", version: "2.0.0"}
      capabilities = %{"tools" => %{}}

      response = Lifecycle.initialize_response(1, server_info, capabilities)

      assert %Response{} = response
      assert response.id == 1
      assert response.result["protocolVersion"] == "2025-11-25"
      assert response.result["serverInfo"]["name"] == "test-server"
      assert response.result["serverInfo"]["version"] == "2.0.0"
      assert response.result["capabilities"] == %{"tools" => %{}}
    end
  end

  describe "initialized_notification/0" do
    test "creates an initialized notification" do
      notification = Lifecycle.initialized_notification()

      assert %Notification{} = notification
      assert notification.method == "notifications/initialized"
      assert notification.params == %{}
    end
  end

  describe "parse_init_params/1" do
    test "parses valid init params" do
      params = %{
        "protocolVersion" => "2025-11-25",
        "capabilities" => %{"tools" => %{}},
        "clientInfo" => %{
          "name" => "test",
          "version" => "1.0"
        }
      }

      assert {:ok, parsed} = Lifecycle.parse_init_params(params)
      assert parsed.protocolVersion == "2025-11-25"
      assert parsed.capabilities == %{"tools" => %{}}
      assert parsed.clientInfo.name == "test"
      assert parsed.clientInfo.version == "1.0"
    end

    test "rejects invalid params" do
      assert {:error, :invalid_init_params} = Lifecycle.parse_init_params(%{})

      assert {:error, :invalid_init_params} =
               Lifecycle.parse_init_params(%{"protocolVersion" => "1.0"})
    end
  end

  describe "validate_protocol_version/1" do
    test "accepts valid version" do
      assert :ok = Lifecycle.validate_protocol_version("2025-11-25")
    end

    test "rejects invalid version" do
      assert {:error, :unsupported_version} = Lifecycle.validate_protocol_version("1.0")
    end
  end
end
