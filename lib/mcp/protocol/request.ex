defmodule MCP.Protocol.Request do
  @moduledoc """
  Represents a JSON-RPC 2.0 request in the MCP protocol.

  A request is sent from the client to the server or vice versa to initiate an operation.
  Requests MUST include a string or integer ID and expect a response.
  """

  alias MCP.Protocol.Message

  @type t :: %__MODULE__{
          id: Message.id(),
          method: String.t(),
          params: Message.params()
        }

  @enforce_keys [:id, :method]
  defstruct [:id, :method, params: %{}]

  @doc """
  Creates a new Request struct.

  ## Examples

      iex> MCP.Protocol.Request.new(1, "initialize", %{})
      %MCP.Protocol.Request{id: 1, method: "initialize", params: %{}}

  """
  @spec new(Message.id(), String.t(), Message.params()) :: t()
  def new(id, method, params \\ %{}) do
    %__MODULE__{id: id, method: method, params: params}
  end

  @doc """
  Parses a decoded JSON map into a Request struct.

  Returns `{:ok, request}` if valid, or `{:error, reason}` otherwise.
  """
  @spec parse(map()) :: {:ok, t()} | {:error, atom()}
  def parse(%{"jsonrpc" => "2.0", "id" => id, "method" => method} = msg)
      when is_binary(method) and (is_binary(id) or is_integer(id)) do
    params = Map.get(msg, "params", %{})
    {:ok, new(id, method, params)}
  end

  def parse(%{"id" => nil}), do: {:error, :null_id_not_allowed}
  def parse(%{"id" => _}), do: {:error, :invalid_request}
  def parse(_), do: {:error, :invalid_request}

  @doc """
  Encodes a Request struct to a JSON-encodable map.
  """
  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{id: id, method: method, params: params}) do
    base = %{
      "jsonrpc" => Message.json_rpc_version(),
      "id" => id,
      "method" => method
    }

    if params == %{} do
      base
    else
      Map.put(base, "params", params)
    end
  end

  @doc """
  Encodes a Request struct to a JSON string.
  """
  @spec encode(t()) :: {:ok, String.t()} | {:error, term()}
  def encode(%__MODULE__{} = request) do
    request
    |> to_map()
    |> Message.encode()
  end
end
