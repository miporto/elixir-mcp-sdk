defmodule MCP.Transport.FramingTest do
  use ExUnit.Case, async: true

  alias MCP.Transport.Framing

  describe "frame/1" do
    test "adds newline delimiter to JSON message" do
      message = %{"jsonrpc" => "2.0", "method" => "test"}
      assert {:ok, framed} = Framing.frame(message)
      assert String.ends_with?(framed, "\n")
    end

    test "encodes message to JSON" do
      message = %{"key" => "value"}
      assert {:ok, framed} = Framing.frame(message)
      assert framed == ~s({"key":"value"}) <> "\n"
    end
  end

  describe "unframe/1" do
    test "decodes JSON and strips newline" do
      data = ~s({"jsonrpc":"2.0","method":"test"}) <> "\n"
      assert {:ok, message} = Framing.unframe(data)
      assert message == %{"jsonrpc" => "2.0", "method" => "test"}
    end

    test "handles data without trailing newline" do
      data = ~s({"key":"value"})
      assert {:ok, message} = Framing.unframe(data)
      assert message == %{"key" => "value"}
    end

    test "returns error for invalid JSON" do
      assert {:error, _} = Framing.unframe("not json\n")
    end
  end

  describe "split_messages/1" do
    test "splits multiple complete messages" do
      buffer = ~s({"a":1}\n{"b":2}\n)
      {messages, remaining} = Framing.split_messages(buffer)

      assert length(messages) == 2
      assert Enum.at(messages, 0) == %{"a" => 1}
      assert Enum.at(messages, 1) == %{"b" => 2}
      assert remaining == ""
    end

    test "handles incomplete message at end" do
      buffer = ~s({"a":1}\n{"b":2}\n{"c":)
      {messages, remaining} = Framing.split_messages(buffer)

      assert length(messages) == 2
      assert remaining == ~s({"c":)
    end

    test "handles empty buffer" do
      {messages, remaining} = Framing.split_messages("")
      assert messages == []
      assert remaining == ""
    end

    test "handles buffer with only incomplete message" do
      buffer = ~s({"incomplete":)
      {messages, remaining} = Framing.split_messages(buffer)

      assert messages == []
      assert remaining == buffer
    end

    test "skips invalid JSON lines" do
      buffer = "not json\n{\"valid\":true}\n"
      {messages, remaining} = Framing.split_messages(buffer)

      assert length(messages) == 1
      assert Enum.at(messages, 0) == %{"valid" => true}
      assert remaining == ""
    end
  end
end
