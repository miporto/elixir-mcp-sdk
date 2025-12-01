defmodule MCP.Protocol.ResponseTest do
  use ExUnit.Case, async: true

  alias MCP.Protocol.Response

  describe "success/2" do
    test "creates a success response" do
      response = Response.success(1, %{"status" => "ok"})

      assert response.id == 1
      assert response.result == %{"status" => "ok"}
      assert response.error == nil
    end
  end

  describe "error/4" do
    test "creates an error response" do
      response = Response.error(1, -32600, "Invalid Request")

      assert response.id == 1
      assert response.result == nil
      assert response.error.code == -32600
      assert response.error.message == "Invalid Request"
      assert response.error.data == nil
    end

    test "creates an error response with data" do
      response = Response.error(1, -32602, "Invalid params", %{"field" => "name"})

      assert response.error.data == %{"field" => "name"}
    end
  end

  describe "parse/1" do
    test "parses a success response" do
      message = %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "result" => %{"value" => 42}
      }

      assert {:ok, response} = Response.parse(message)
      assert response.id == 1
      assert response.result == %{"value" => 42}
      assert response.error == nil
    end

    test "parses an error response" do
      message = %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "error" => %{
          "code" => -32601,
          "message" => "Method not found"
        }
      }

      assert {:ok, response} = Response.parse(message)
      assert response.id == 1
      assert response.result == nil
      assert response.error.code == -32601
      assert response.error.message == "Method not found"
    end

    test "rejects response with both result and error" do
      message = %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "result" => %{},
        "error" => %{"code" => -1, "message" => "err"}
      }

      assert {:error, :both_result_and_error} = Response.parse(message)
    end

    test "rejects invalid error format" do
      message = %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "error" => %{"code" => "not an int", "message" => "err"}
      }

      assert {:error, :invalid_error_format} = Response.parse(message)
    end
  end

  describe "to_map/1" do
    test "converts success response to map" do
      response = Response.success(1, %{"ok" => true})
      map = Response.to_map(response)

      assert map == %{
               "jsonrpc" => "2.0",
               "id" => 1,
               "result" => %{"ok" => true}
             }
    end

    test "converts error response to map" do
      response = Response.error(1, -32600, "Invalid")
      map = Response.to_map(response)

      assert map == %{
               "jsonrpc" => "2.0",
               "id" => 1,
               "error" => %{"code" => -32600, "message" => "Invalid"}
             }
    end

    test "includes error data when present" do
      response = Response.error(1, -32602, "Invalid params", %{"extra" => "info"})
      map = Response.to_map(response)

      assert map["error"]["data"] == %{"extra" => "info"}
    end
  end

  describe "encode/1" do
    test "encodes response to JSON string" do
      response = Response.success(1, %{})
      assert {:ok, json} = Response.encode(response)
      decoded = :json.decode(json)
      assert decoded["jsonrpc"] == "2.0"
      assert decoded["id"] == 1
      assert decoded["result"] == %{}
    end
  end
end
