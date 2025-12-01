defmodule MCP.Protocol.ErrorCodes do
  @moduledoc """
  Standard JSON-RPC 2.0 error codes and MCP-specific error codes.

  JSON-RPC reserves error codes from -32768 to -32000 for protocol-defined errors.
  MCP-specific errors use codes in the -32000 to -32099 range.
  """

  @doc "Invalid JSON was received by the server."
  def parse_error, do: -32700

  @doc "The JSON sent is not a valid Request object."
  def invalid_request, do: -32600

  @doc "The method does not exist or is not available."
  def method_not_found, do: -32601

  @doc "Invalid method parameter(s)."
  def invalid_params, do: -32602

  @doc "Internal JSON-RPC error."
  def internal_error, do: -32603

  @doc "Returns the error message for a given error code."
  @spec message(integer()) :: String.t()
  def message(-32700), do: "Parse error"
  def message(-32600), do: "Invalid Request"
  def message(-32601), do: "Method not found"
  def message(-32602), do: "Invalid params"
  def message(-32603), do: "Internal error"
  def message(_code), do: "Unknown error"
end
