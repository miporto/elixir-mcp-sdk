defmodule MCP.Server.Handler do
  @moduledoc """
  Behaviour for implementing MCP server handlers.

  Implement this behaviour to create an MCP server that handles
  requests, notifications, and lifecycle events.
  """

  alias MCP.Protocol.{Request, Notification, Response}

  @type server_info :: %{name: String.t(), version: String.t()}
  @type capabilities :: map()

  @doc """
  Returns the server information.
  """
  @callback server_info() :: server_info()

  @doc """
  Returns the server's capabilities.
  """
  @callback capabilities() :: capabilities()

  @doc """
  Called when the server receives an initialize request.

  The default implementation returns the server info and capabilities.
  Override to add custom initialization logic.
  """
  @callback handle_initialize(params :: map()) ::
              {:ok, map()} | {:error, integer(), String.t()}

  @doc """
  Called when the server receives an initialized notification.
  """
  @callback handle_initialized() :: :ok

  @doc """
  Called when the server receives a request.

  Return `{:ok, result}` to send a successful response,
  or `{:error, code, message}` to send an error response.
  """
  @callback handle_request(Request.t()) ::
              {:ok, map()} | {:error, integer(), String.t()}

  @doc """
  Called when the server receives a notification.
  """
  @callback handle_notification(Notification.t()) :: :ok

  @optional_callbacks [handle_initialize: 1, handle_initialized: 0]

  defmacro __using__(_opts) do
    quote do
      @behaviour MCP.Server.Handler

      alias MCP.Protocol.{Request, Response, Notification, Lifecycle, ErrorCodes}

      @impl true
      def handle_initialize(_params) do
        result = %{
          "protocolVersion" => Lifecycle.protocol_version(),
          "capabilities" => capabilities(),
          "serverInfo" => %{
            "name" => server_info().name,
            "version" => server_info().version
          }
        }

        {:ok, result}
      end

      @impl true
      def handle_initialized, do: :ok

      @impl true
      def handle_request(%Request{method: method}) do
        {:error, ErrorCodes.method_not_found(), "Method not found: #{method}"}
      end

      @impl true
      def handle_notification(_notification), do: :ok

      defoverridable handle_initialize: 1,
                     handle_initialized: 0,
                     handle_request: 1,
                     handle_notification: 1
    end
  end
end
