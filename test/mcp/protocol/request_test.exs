defmodule MCP.Protocol.RequestTest do
  use ExUnit.Case, async: true

  alias MCP.Protocol.Request

  describe "new/3" do
    test "creates a request with all fields" do
      request = Request.new(1, "test/method", %{"key" => "value"})

      assert request.id == 1
      assert request.method == "test/method"
      assert request.params == %{"key" => "value"}
    end

    test "creates a request with default empty params" do
      request = Request.new("abc", "test")

      assert request.id == "abc"
      assert request.method == "test"
      assert request.params == %{}
    end
  end

  describe "parse/1" do
    test "parses a valid request with integer id" do
      message = %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "method" => "initialize",
        "params" => %{"foo" => "bar"}
      }

      assert {:ok, request} = Request.parse(message)
      assert request.id == 1
      assert request.method == "initialize"
      assert request.params == %{"foo" => "bar"}
    end

    test "parses a valid request with string id" do
      message = %{
        "jsonrpc" => "2.0",
        "id" => "abc-123",
        "method" => "tools/list"
      }

      assert {:ok, request} = Request.parse(message)
      assert request.id == "abc-123"
      assert request.method == "tools/list"
      assert request.params == %{}
    end

    test "rejects null id" do
      message = %{
        "jsonrpc" => "2.0",
        "id" => nil,
        "method" => "test"
      }

      assert {:error, :null_id_not_allowed} = Request.parse(message)
    end

    test "rejects missing jsonrpc version" do
      message = %{"id" => 1, "method" => "test"}
      assert {:error, :invalid_request} = Request.parse(message)
    end

    test "rejects missing method" do
      message = %{"jsonrpc" => "2.0", "id" => 1}
      assert {:error, :invalid_request} = Request.parse(message)
    end
  end

  describe "to_map/1" do
    test "converts request to map with params" do
      request = Request.new(1, "test", %{"key" => "value"})
      map = Request.to_map(request)

      assert map == %{
               "jsonrpc" => "2.0",
               "id" => 1,
               "method" => "test",
               "params" => %{"key" => "value"}
             }
    end

    test "omits params when empty" do
      request = Request.new(1, "test")
      map = Request.to_map(request)

      refute Map.has_key?(map, "params")
    end
  end

  describe "encode/1" do
    test "encodes request to JSON string" do
      request = Request.new(1, "ping")
      assert {:ok, json} = Request.encode(request)
      decoded = :json.decode(json)
      assert decoded["jsonrpc"] == "2.0"
      assert decoded["id"] == 1
      assert decoded["method"] == "ping"
    end
  end
end
