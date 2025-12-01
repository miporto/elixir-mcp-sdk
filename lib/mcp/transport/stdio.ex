defmodule MCP.Transport.Stdio do
  @moduledoc """
  Stdio transport implementation for MCP.

  In the stdio transport:
  - The server reads JSON-RPC messages from stdin
  - The server writes messages to stdout
  - Messages are newline-delimited JSON
  - The server MAY write to stderr for logging

  This module provides a GenServer that manages stdio communication.
  """

  use GenServer

  alias MCP.Transport.Framing

  @type state :: %{
          buffer: String.t(),
          handler: module() | pid(),
          input: :stdio | pid(),
          output: :stdio | pid()
        }

  defmodule Behaviour do
    @moduledoc """
    Behaviour for handling incoming MCP messages.
    """

    @callback handle_message(map()) :: {:ok, map() | nil} | {:error, term()}
  end

  @doc """
  Starts the Stdio transport.

  ## Options

    - `:handler` - Module or pid that implements the message handler (required)
    - `:input` - Input source, defaults to `:stdio`
    - `:output` - Output destination, defaults to `:stdio`

  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name))
  end

  @doc """
  Sends a message to the transport output.
  """
  @spec send_message(GenServer.server(), map()) :: :ok | {:error, term()}
  def send_message(transport, message) do
    GenServer.call(transport, {:send, message})
  end

  @impl true
  def init(opts) do
    handler = Keyword.fetch!(opts, :handler)
    input = Keyword.get(opts, :input, :stdio)
    output = Keyword.get(opts, :output, :stdio)

    state = %{
      buffer: "",
      handler: handler,
      input: input,
      output: output
    }

    if input == :stdio do
      :ok = :io.setopts(:standard_io, binary: true, encoding: :latin1)
      schedule_read()
    end

    {:ok, state}
  end

  @impl true
  def handle_call({:send, message}, _from, state) do
    result = write_message(message, state.output)
    {:reply, result, state}
  end

  @impl true
  def handle_info(:read_stdin, state) do
    new_state = read_and_process(state)
    schedule_read()
    {:noreply, new_state}
  end

  def handle_info({:input, data}, state) when is_binary(data) do
    new_state = process_input(state, data)
    {:noreply, new_state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp schedule_read do
    send(self(), :read_stdin)
  end

  defp read_and_process(state) do
    case read_available(state.input) do
      {:ok, ""} ->
        state

      {:ok, data} ->
        process_input(state, data)

      {:error, _reason} ->
        state
    end
  end

  defp read_available(:stdio) do
    case :io.get_line(:standard_io, "") do
      :eof -> {:ok, ""}
      {:error, reason} -> {:error, reason}
      data when is_binary(data) -> {:ok, data}
      data when is_list(data) -> {:ok, IO.iodata_to_binary(data)}
    end
  end

  defp read_available(pid) when is_pid(pid) do
    receive do
      {:input, data} -> {:ok, data}
    after
      0 -> {:ok, ""}
    end
  end

  defp process_input(state, data) do
    buffer = state.buffer <> data
    {messages, remaining} = Framing.split_messages(buffer)

    Enum.each(messages, fn msg ->
      handle_incoming_message(msg, state)
    end)

    %{state | buffer: remaining}
  end

  defp handle_incoming_message(message, state) do
    case dispatch_to_handler(message, state.handler) do
      {:ok, nil} ->
        :ok

      {:ok, response} ->
        write_message(response, state.output)

      {:error, _reason} ->
        :ok
    end
  end

  defp dispatch_to_handler(message, handler) when is_atom(handler) do
    handler.handle_message(message)
  end

  defp dispatch_to_handler(message, handler) when is_pid(handler) do
    GenServer.call(handler, {:mcp_message, message})
  end

  defp write_message(message, :stdio) do
    case Framing.frame(message) do
      {:ok, framed} ->
        IO.write(framed)
        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp write_message(message, pid) when is_pid(pid) do
    case Framing.frame(message) do
      {:ok, framed} ->
        send(pid, {:output, framed})
        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end
end
