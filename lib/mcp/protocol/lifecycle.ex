defmodule MCP.Protocol.Lifecycle do
  @moduledoc """
  Handles the MCP lifecycle including initialization handshake.

  The MCP lifecycle consists of:
  1. Client sends `initialize` request with capabilities
  2. Server responds with its capabilities
  3. Client sends `initialized` notification
  4. Normal operation begins
  """

  alias MCP.Protocol.{Request, Response, Notification}

  @protocol_version "2025-11-25"

  @type client_info :: %{
          name: String.t(),
          version: String.t()
        }

  @type server_info :: %{
          name: String.t(),
          version: String.t()
        }

  @type capabilities :: %{
          optional(:tools) => map(),
          optional(:resources) => map(),
          optional(:prompts) => map(),
          optional(:logging) => map()
        }

  @type init_params :: %{
          protocolVersion: String.t(),
          capabilities: capabilities(),
          clientInfo: client_info()
        }

  @type init_result :: %{
          protocolVersion: String.t(),
          capabilities: capabilities(),
          serverInfo: server_info()
        }

  @doc """
  Returns the current MCP protocol version.
  """
  @spec protocol_version() :: String.t()
  def protocol_version, do: @protocol_version

  @doc """
  Creates an initialize request.

  ## Parameters

    - `id` - The request ID
    - `client_info` - Map with :name and :version of the client
    - `capabilities` - Map of client capabilities

  ## Examples

      iex> MCP.Protocol.Lifecycle.initialize_request(1, %{name: "test", version: "1.0"}, %{})
      %MCP.Protocol.Request{id: 1, method: "initialize", params: %{...}}

  """
  @spec initialize_request(Request.id(), client_info(), capabilities()) :: Request.t()
  def initialize_request(id, client_info, capabilities \\ %{}) do
    params = %{
      "protocolVersion" => @protocol_version,
      "capabilities" => capabilities,
      "clientInfo" => %{
        "name" => client_info.name,
        "version" => client_info.version
      }
    }

    Request.new(id, "initialize", params)
  end

  @doc """
  Creates an initialize response (server's reply to initialize request).

  ## Parameters

    - `id` - The request ID (must match the request)
    - `server_info` - Map with :name and :version of the server
    - `capabilities` - Map of server capabilities

  """
  @spec initialize_response(Request.id(), server_info(), capabilities()) :: Response.t()
  def initialize_response(id, server_info, capabilities \\ %{}) do
    result = %{
      "protocolVersion" => @protocol_version,
      "capabilities" => capabilities,
      "serverInfo" => %{
        "name" => server_info.name,
        "version" => server_info.version
      }
    }

    Response.success(id, result)
  end

  @doc """
  Creates an initialized notification (sent by client after receiving initialize response).
  """
  @spec initialized_notification() :: Notification.t()
  def initialized_notification do
    Notification.new("notifications/initialized")
  end

  @doc """
  Parses an initialize request params and validates the structure.
  """
  @spec parse_init_params(map()) :: {:ok, init_params()} | {:error, atom()}
  def parse_init_params(%{
        "protocolVersion" => version,
        "capabilities" => capabilities,
        "clientInfo" => %{"name" => name, "version" => client_version}
      })
      when is_binary(version) and is_map(capabilities) and is_binary(name) and
             is_binary(client_version) do
    {:ok,
     %{
       protocolVersion: version,
       capabilities: capabilities,
       clientInfo: %{name: name, version: client_version}
     }}
  end

  def parse_init_params(_), do: {:error, :invalid_init_params}

  @doc """
  Validates that the protocol version is supported.
  """
  @spec validate_protocol_version(String.t()) :: :ok | {:error, :unsupported_version}
  def validate_protocol_version(@protocol_version), do: :ok
  def validate_protocol_version(_), do: {:error, :unsupported_version}
end
