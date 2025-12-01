defmodule MCP.Server.Router do
  @moduledoc """
  Request routing utilities for MCP servers.

  This module provides helpers for routing MCP requests to the appropriate
  handler functions based on the method name.
  """

  alias MCP.Protocol.{Request, ErrorCodes}

  @type route :: {String.t(), atom()}
  @type routes :: [route()]

  @doc """
  Routes a request to the appropriate handler function.

  ## Parameters

    - `request` - The MCP request to route
    - `handler_module` - The module containing handler functions
    - `routes` - List of `{method, function_name}` tuples

  ## Returns

    - `{:ok, result}` if the handler succeeds
    - `{:error, code, message}` if the handler fails or method not found

  ## Example

      routes = [
        {"tools/list", :handle_tools_list},
        {"tools/call", :handle_tools_call}
      ]

      Router.route(request, MyHandler, routes)

  """
  @spec route(Request.t(), module(), routes()) ::
          {:ok, map()} | {:error, integer(), String.t()}
  def route(%Request{method: method, params: params}, handler_module, routes) do
    case find_route(method, routes) do
      {:ok, function} ->
        apply(handler_module, function, [params])

      :not_found ->
        {:error, ErrorCodes.method_not_found(), "Method not found: #{method}"}
    end
  end

  @doc """
  Creates a routing function for use in handler modules.

  ## Example

      defmodule MyHandler do
        use MCP.Server.Handler

        @routes [
          {"tools/list", :handle_tools_list},
          {"tools/call", :handle_tools_call}
        ]

        @impl true
        def handle_request(request) do
          Router.route(request, __MODULE__, @routes)
        end

        def handle_tools_list(_params), do: {:ok, %{"tools" => []}}
        def handle_tools_call(params), do: {:ok, %{"result" => params}}
      end

  """
  @spec find_route(String.t(), routes()) :: {:ok, atom()} | :not_found
  def find_route(method, routes) do
    case Enum.find(routes, fn {m, _} -> m == method end) do
      {_, function} -> {:ok, function}
      nil -> :not_found
    end
  end

  @doc """
  Validates that a request method is in the allowed list.
  """
  @spec method_allowed?(String.t(), [String.t()]) :: boolean()
  def method_allowed?(method, allowed_methods) do
    method in allowed_methods
  end
end
