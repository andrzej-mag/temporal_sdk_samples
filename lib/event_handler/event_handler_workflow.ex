defmodule EventHandler.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @impl true
  def execute(_context, _input) do
    start_execution(:event_iterator, 1)
    start_activity(:echo_activity, [])
    start_activity(:echo_activity, [[], 5_000])
    :ok
  end

  def event_iterator(%{}, event_id) do
    case await({:event, {event_id, :_, :_, :_}}) do
      {:noevent, :noevent} ->
        IO.puts("NOEVENT")

      {:ok, %{event_id: event_id, type: type}} ->
        IO.puts("#{event_id}: #{type}")
        event_iterator(%{}, event_id + 1)
    end
  end
end
