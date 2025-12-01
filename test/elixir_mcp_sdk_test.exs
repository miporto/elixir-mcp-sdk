defmodule ElixirMcpSdkTest do
  use ExUnit.Case

  describe "protocol_version/0" do
    test "returns the MCP protocol version" do
      assert ElixirMcpSdk.protocol_version() == "2025-11-25"
    end
  end

  describe "version/0" do
    test "returns the SDK version" do
      assert ElixirMcpSdk.version() == "0.1.0"
    end
  end
end
