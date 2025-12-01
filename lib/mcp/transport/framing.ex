defmodule MCP.Transport.Framing do
  @moduledoc """
  Message framing utilities for MCP transports.

  MCP messages are newline-delimited JSON. Each message is a complete JSON object
  followed by a newline character. Messages MUST NOT contain embedded newlines.
  """

  alias MCP.Protocol.Message

  @doc """
  Frames a message for transmission by encoding to JSON and appending a newline.

  ## Examples

      iex> MCP.Transport.Framing.frame(%{"jsonrpc" => "2.0", "method" => "test"})
      {:ok, ~s({"jsonrpc":"2.0","method":"test"}) <> "\\n"}

  """
  @spec frame(map()) :: {:ok, String.t()} | {:error, term()}
  def frame(message) when is_map(message) do
    case Message.encode(message) do
      {:ok, json} -> {:ok, json <> "\n"}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Unframes a message by stripping the trailing newline and decoding JSON.

  ## Examples

      iex> MCP.Transport.Framing.unframe(~s({"jsonrpc":"2.0","method":"test"}\\n))
      {:ok, %{"jsonrpc" => "2.0", "method" => "test"}}

  """
  @spec unframe(String.t()) :: {:ok, map()} | {:error, term()}
  def unframe(data) when is_binary(data) do
    data
    |> String.trim_trailing("\n")
    |> Message.decode()
  end

  @doc """
  Splits a buffer into complete messages and remaining incomplete data.

  Returns `{complete_messages, remaining_buffer}`.

  ## Examples

      iex> MCP.Transport.Framing.split_messages(~s({"a":1}\\n{"b":2}\\n{"c":3))
      {[%{"a" => 1}, %{"b" => 2}], ~s({"c":3)}

  """
  @spec split_messages(String.t()) :: {[map()], String.t()}
  def split_messages(buffer) when is_binary(buffer) do
    lines = String.split(buffer, "\n", trim: false)

    case List.pop_at(lines, -1) do
      {nil, []} ->
        {[], ""}

      {incomplete, complete_lines} ->
        messages =
          complete_lines
          |> Enum.filter(&(&1 != ""))
          |> Enum.map(fn line ->
            case Message.decode(line) do
              {:ok, msg} -> msg
              {:error, _} -> nil
            end
          end)
          |> Enum.filter(&(&1 != nil))

        {messages, incomplete}
    end
  end
end
