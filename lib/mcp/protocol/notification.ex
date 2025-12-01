defmodule MCP.Protocol.Notification do
  @moduledoc """
  Represents a JSON-RPC 2.0 notification in the MCP protocol.

  Notifications are one-way messages that do not expect a response.
  They MUST NOT include an ID field.
  """

  alias MCP.Protocol.Message

  @type t :: %__MODULE__{
          method: String.t(),
          params: Message.params()
        }

  @enforce_keys [:method]
  defstruct [:method, params: %{}]

  @doc """
  Creates a new Notification struct.

  ## Examples

      iex> MCP.Protocol.Notification.new("initialized")
      %MCP.Protocol.Notification{method: "initialized", params: %{}}

  """
  @spec new(String.t(), Message.params()) :: t()
  def new(method, params \\ %{}) do
    %__MODULE__{method: method, params: params}
  end

  @doc """
  Parses a decoded JSON map into a Notification struct.

  Returns `{:ok, notification}` if valid, or `{:error, reason}` otherwise.
  A notification must NOT have an id field.
  """
  @spec parse(map()) :: {:ok, t()} | {:error, atom()}
  def parse(%{"jsonrpc" => "2.0", "method" => method} = msg)
      when is_binary(method) do
    if Map.has_key?(msg, "id") do
      {:error, :notification_has_id}
    else
      params = Map.get(msg, "params", %{})
      {:ok, new(method, params)}
    end
  end

  def parse(_), do: {:error, :invalid_notification}

  @doc """
  Encodes a Notification struct to a JSON-encodable map.
  """
  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{method: method, params: params}) do
    base = %{
      "jsonrpc" => Message.json_rpc_version(),
      "method" => method
    }

    if params == %{} do
      base
    else
      Map.put(base, "params", params)
    end
  end

  @doc """
  Encodes a Notification struct to a JSON string.
  """
  @spec encode(t()) :: {:ok, String.t()} | {:error, term()}
  def encode(%__MODULE__{} = notification) do
    notification
    |> to_map()
    |> Message.encode()
  end
end
