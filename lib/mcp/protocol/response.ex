defmodule MCP.Protocol.Response do
  @moduledoc """
  Represents a JSON-RPC 2.0 response in the MCP protocol.

  Responses are sent in reply to requests and contain either a result or an error.
  A response MUST NOT contain both result and error.
  """

  alias MCP.Protocol.Message

  @type t :: %__MODULE__{
          id: Message.id(),
          result: map() | nil,
          error: error() | nil
        }

  @type error :: %{
          code: integer(),
          message: String.t(),
          data: term() | nil
        }

  @enforce_keys [:id]
  defstruct [:id, :result, :error]

  @doc """
  Creates a successful response with a result.

  ## Examples

      iex> MCP.Protocol.Response.success(1, %{"status" => "ok"})
      %MCP.Protocol.Response{id: 1, result: %{"status" => "ok"}, error: nil}

  """
  @spec success(Message.id(), map()) :: t()
  def success(id, result) when is_map(result) do
    %__MODULE__{id: id, result: result, error: nil}
  end

  @doc """
  Creates an error response.

  ## Examples

      iex> MCP.Protocol.Response.error(1, -32600, "Invalid Request")
      %MCP.Protocol.Response{id: 1, result: nil, error: %{code: -32600, message: "Invalid Request", data: nil}}

  """
  @spec error(Message.id(), integer(), String.t(), term()) :: t()
  def error(id, code, message, data \\ nil) do
    %__MODULE__{
      id: id,
      result: nil,
      error: %{code: code, message: message, data: data}
    }
  end

  @doc """
  Parses a decoded JSON map into a Response struct.
  """
  @spec parse(map()) :: {:ok, t()} | {:error, atom()}
  def parse(%{"jsonrpc" => "2.0", "id" => _, "result" => _, "error" => _}) do
    {:error, :both_result_and_error}
  end

  def parse(%{"jsonrpc" => "2.0", "id" => id, "result" => result})
      when is_map(result) do
    {:ok, success(id, result)}
  end

  def parse(%{"jsonrpc" => "2.0", "id" => id, "error" => error_map})
      when is_map(error_map) do
    code = Map.get(error_map, "code")
    message = Map.get(error_map, "message", "")
    data = Map.get(error_map, "data")

    if is_integer(code) and is_binary(message) do
      {:ok, error(id, code, message, data)}
    else
      {:error, :invalid_error_format}
    end
  end

  def parse(_), do: {:error, :invalid_response}

  @doc """
  Encodes a Response struct to a JSON-encodable map.
  """
  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{id: id, result: result, error: nil}) do
    %{
      "jsonrpc" => Message.json_rpc_version(),
      "id" => id,
      "result" => result
    }
  end

  def to_map(%__MODULE__{id: id, result: nil, error: error}) do
    error_map =
      %{"code" => error.code, "message" => error.message}
      |> maybe_add_data(error.data)

    %{
      "jsonrpc" => Message.json_rpc_version(),
      "id" => id,
      "error" => error_map
    }
  end

  defp maybe_add_data(map, nil), do: map
  defp maybe_add_data(map, data), do: Map.put(map, "data", data)

  @doc """
  Encodes a Response struct to a JSON string.
  """
  @spec encode(t()) :: {:ok, String.t()} | {:error, term()}
  def encode(%__MODULE__{} = response) do
    response
    |> to_map()
    |> Message.encode()
  end
end
