defmodule MCP.Protocol.MessageTest do
  use ExUnit.Case, async: true

  alias MCP.Protocol.Message

  describe "json_rpc_version/0" do
    test "returns the JSON-RPC version" do
      assert Message.json_rpc_version() == "2.0"
    end
  end

  describe "encode/1" do
    test "encodes a map to JSON" do
      assert {:ok, json} = Message.encode(%{"key" => "value"})
      assert json == ~s({"key":"value"})
    end

    test "encodes nested maps" do
      input = %{"outer" => %{"inner" => "value"}}
      assert {:ok, json} = Message.encode(input)
      assert json == ~s({"outer":{"inner":"value"}})
    end
  end

  describe "decode/1" do
    test "decodes valid JSON" do
      assert {:ok, %{"key" => "value"}} = Message.decode(~s({"key":"value"}))
    end

    test "returns error for invalid JSON" do
      assert {:error, {:parse_error, _}} = Message.decode("not json")
    end
  end

  describe "validate_version/1" do
    test "returns :ok for valid version" do
      assert :ok = Message.validate_version(%{"jsonrpc" => "2.0"})
    end

    test "returns error for missing version" do
      assert {:error, :invalid_version} = Message.validate_version(%{})
    end

    test "returns error for wrong version" do
      assert {:error, :invalid_version} = Message.validate_version(%{"jsonrpc" => "1.0"})
    end
  end
end
