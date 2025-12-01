defmodule ElixirMcpSdk do
  @moduledoc """
  Elixir SDK for the Model Context Protocol (MCP).

  This SDK provides a complete implementation of the MCP protocol for building
  MCP servers and clients in Elixir. The SDK is designed to be modular, allowing
  users to choose their preferred HTTP server implementations (Bandit, Cowboy, etc.).

  ## Core Modules

  ### Protocol Layer (`MCP.Protocol`)

  - `MCP.Protocol.Message` - Base JSON-RPC 2.0 message handling
  - `MCP.Protocol.Request` - Request message type
  - `MCP.Protocol.Response` - Response message type
  - `MCP.Protocol.Notification` - Notification message type
  - `MCP.Protocol.Lifecycle` - Initialize/initialized handshake
  - `MCP.Protocol.ErrorCodes` - Standard JSON-RPC error codes

  ### Transport Layer (`MCP.Transport`)

  - `MCP.Transport.Stdio` - Stdio transport implementation
  - `MCP.Transport.HTTP` - HTTP transport interface
  - `MCP.Transport.Framing` - Message framing utilities

  ### Server Framework (`MCP.Server`)

  - `MCP.Server.Handler` - Handler behaviour for implementing servers
  - `MCP.Server.Connection` - Connection lifecycle management
  - `MCP.Server.Router` - Request routing utilities

  ## Quick Start

  To create an MCP server, implement the `MCP.Server.Handler` behaviour:

      defmodule MyMCPServer do
        use MCP.Server.Handler

        @impl true
        def server_info, do: %{name: "my-server", version: "1.0.0"}

        @impl true
        def capabilities, do: %{}

        @impl true
        def handle_request(request) do
          # Handle your custom requests here
          {:error, MCP.Protocol.ErrorCodes.method_not_found(), "Unknown method"}
        end
      end

  ## Protocol Version

  This SDK implements MCP protocol version #{MCP.Protocol.Lifecycle.protocol_version()}.
  """

  @doc """
  Returns the current MCP protocol version supported by this SDK.
  """
  @spec protocol_version() :: String.t()
  def protocol_version do
    MCP.Protocol.Lifecycle.protocol_version()
  end

  @doc """
  Returns the SDK version.
  """
  @spec version() :: String.t()
  def version do
    "0.1.0"
  end
end
