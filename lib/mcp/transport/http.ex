defmodule MCP.Transport.HTTP do
  @moduledoc """
  HTTP transport interface for MCP.

  This module provides the interface and utilities for implementing HTTP-based
  MCP transports. Users can integrate with their preferred HTTP server
  (Bandit, Cowboy, etc.) using the callbacks and helpers provided here.

  The HTTP transport supports:
  - Streamable HTTP (replaces the older HTTP+SSE transport)
  - Session management via Mcp-Session-Id header
  - Both POST (for requests) and GET (for SSE streams) methods
  """

  alias MCP.Protocol.{Message, Response}
  alias MCP.Protocol.ErrorCodes

  @type session_id :: String.t()

  @doc """
  Parses an incoming HTTP request body as an MCP message.
  """
  @spec parse_request_body(String.t()) :: {:ok, map()} | {:error, Response.t()}
  def parse_request_body(body) do
    case Message.decode(body) do
      {:ok, message} ->
        {:ok, message}

      {:error, _} ->
        error_response =
          Response.error(nil, ErrorCodes.parse_error(), "Parse error")

        {:error, error_response}
    end
  end

  @doc """
  Formats a response for HTTP transmission.

  Returns `{status_code, content_type, body}`.
  """
  @spec format_response(Response.t()) :: {integer(), String.t(), String.t()}
  def format_response(%Response{} = response) do
    case Response.encode(response) do
      {:ok, body} ->
        {200, "application/json", body}

      {:error, _} ->
        {500, "application/json", ~s({"error": "Failed to encode response"})}
    end
  end

  @doc """
  Formats an accepted response (HTTP 202) for notifications.
  """
  @spec format_accepted() :: {integer(), String.t(), String.t()}
  def format_accepted do
    {202, "application/json", ""}
  end

  @doc """
  Generates a cryptographically secure session ID.
  """
  @spec generate_session_id() :: session_id()
  def generate_session_id do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64(padding: false)
  end

  @doc """
  Validates the MCP-Protocol-Version header.
  """
  @spec validate_protocol_version_header(String.t() | nil) :: :ok | {:error, :invalid_version}
  def validate_protocol_version_header(nil), do: :ok
  def validate_protocol_version_header("2025-11-25"), do: :ok
  def validate_protocol_version_header(_), do: {:error, :invalid_version}

  @doc """
  Returns the required headers for an MCP HTTP response.
  """
  @spec response_headers(keyword()) :: [{String.t(), String.t()}]
  def response_headers(opts \\ []) do
    base = [
      {"Content-Type", "application/json"}
    ]

    case Keyword.get(opts, :session_id) do
      nil -> base
      session_id -> [{"Mcp-Session-Id", session_id} | base]
    end
  end
end
