defmodule MCP.Protocol.Message do
  @moduledoc """
  Base module for MCP JSON-RPC 2.0 message handling.

  Provides common functionality for parsing and encoding JSON-RPC messages
  according to the MCP specification.
  """

  @json_rpc_version "2.0"

  @type id :: String.t() | integer()
  @type params :: map()

  @doc """
  Returns the JSON-RPC version string.
  """
  @spec json_rpc_version() :: String.t()
  def json_rpc_version, do: @json_rpc_version

  @doc """
  Encodes a map to JSON using Elixir's stdlib :json module.
  """
  @spec encode(map()) :: {:ok, String.t()} | {:error, term()}
  def encode(message) when is_map(message) do
    {:ok, IO.iodata_to_binary(:json.encode(message))}
  rescue
    e -> {:error, e}
  end

  @doc """
  Decodes a JSON string to a map using Elixir's stdlib :json module.
  """
  @spec decode(String.t()) :: {:ok, map()} | {:error, term()}
  def decode(json) when is_binary(json) do
    {:ok, :json.decode(json)}
  rescue
    e -> {:error, {:parse_error, e}}
  end

  @doc """
  Validates that a message has the required JSON-RPC version.
  """
  @spec validate_version(map()) :: :ok | {:error, :invalid_version}
  def validate_version(%{"jsonrpc" => @json_rpc_version}), do: :ok
  def validate_version(_), do: {:error, :invalid_version}
end
