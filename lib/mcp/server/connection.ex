defmodule MCP.Server.Connection do
  @moduledoc """
  Manages an MCP server connection lifecycle.

  This GenServer handles:
  - Connection state (uninitialized, initializing, ready, closed)
  - Message routing to the handler
  - Response generation
  """

  use GenServer

  alias MCP.Protocol.{Request, Response, Notification, ErrorCodes}

  @type state :: :uninitialized | :initializing | :ready | :closed

  @type t :: %{
          state: state(),
          handler: module(),
          handler_state: term()
        }

  @doc """
  Starts a new connection.

  ## Options

    - `:handler` - The handler module implementing `MCP.Server.Handler` (required)

  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name))
  end

  @doc """
  Processes an incoming message and returns the response if any.
  """
  @spec handle_message(GenServer.server(), map()) :: {:ok, map() | nil} | {:error, term()}
  def handle_message(connection, message) do
    GenServer.call(connection, {:message, message})
  end

  @doc """
  Returns the current connection state.
  """
  @spec get_state(GenServer.server()) :: state()
  def get_state(connection) do
    GenServer.call(connection, :get_state)
  end

  @impl true
  def init(opts) do
    handler = Keyword.fetch!(opts, :handler)

    {:ok,
     %{
       state: :uninitialized,
       handler: handler,
       handler_state: nil
     }}
  end

  @impl true
  def handle_call({:message, message}, _from, state) do
    {response, new_state} = process_message(message, state)
    {:reply, {:ok, response}, new_state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state.state, state}
  end

  defp process_message(message, state) do
    cond do
      is_request?(message) ->
        process_request(message, state)

      is_notification?(message) ->
        process_notification(message, state)

      true ->
        error_response = Response.error(nil, ErrorCodes.invalid_request(), "Invalid Request")
        {Response.to_map(error_response), state}
    end
  end

  defp is_request?(message) do
    Map.has_key?(message, "id") and Map.has_key?(message, "method")
  end

  defp is_notification?(message) do
    not Map.has_key?(message, "id") and Map.has_key?(message, "method")
  end

  defp process_request(message, state) do
    case Request.parse(message) do
      {:ok, request} ->
        handle_request(request, state)

      {:error, reason} ->
        id = Map.get(message, "id")
        error_response = Response.error(id, ErrorCodes.invalid_request(), "#{reason}")
        {Response.to_map(error_response), state}
    end
  end

  defp process_notification(message, state) do
    case Notification.parse(message) do
      {:ok, notification} ->
        new_state = handle_notification(notification, state)
        {nil, new_state}

      {:error, _reason} ->
        {nil, state}
    end
  end

  defp handle_request(%Request{method: "initialize"} = request, state) do
    if state.state != :uninitialized do
      error_response =
        Response.error(request.id, ErrorCodes.invalid_request(), "Already initialized")

      {Response.to_map(error_response), state}
    else
      new_state = %{state | state: :initializing}

      case state.handler.handle_initialize(request.params) do
        {:ok, result} ->
          response = Response.success(request.id, result)
          {Response.to_map(response), new_state}

        {:error, code, message} ->
          error_response = Response.error(request.id, code, message)
          {Response.to_map(error_response), state}
      end
    end
  end

  defp handle_request(%Request{method: "ping"} = request, state) do
    response = Response.success(request.id, %{})
    {Response.to_map(response), state}
  end

  defp handle_request(%Request{} = request, state) do
    if state.state != :ready do
      error_response =
        Response.error(request.id, ErrorCodes.invalid_request(), "Server not initialized")

      {Response.to_map(error_response), state}
    else
      case state.handler.handle_request(request) do
        {:ok, result} ->
          response = Response.success(request.id, result)
          {Response.to_map(response), state}

        {:error, code, message} ->
          error_response = Response.error(request.id, code, message)
          {Response.to_map(error_response), state}
      end
    end
  end

  defp handle_notification(%Notification{method: "notifications/initialized"}, state) do
    if state.state == :initializing do
      state.handler.handle_initialized()
      %{state | state: :ready}
    else
      state
    end
  end

  defp handle_notification(%Notification{} = notification, state) do
    if state.state == :ready do
      state.handler.handle_notification(notification)
    end

    state
  end
end
