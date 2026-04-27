defmodule EvictionParallelHandler.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @activity_count 3
  @activity_sleep 500
  @urgent_signal "urgent_signal"
  @eviction_hsb 500_000

  @impl true
  def execute(_context, [[activity_payload_size, handle_eviction_strategy]])
      when is_integer(activity_payload_size) and is_binary(handle_eviction_strategy) do
    start_execution(:eviction_handler, {String.to_existing_atom(handle_eviction_strategy), 1})
    activity_payload = String.duplicate("X", activity_payload_size)
    run_blocking_activities(activity_payload, @activity_count)

    await_result =
      TemporalSdk.Workflow.await({:signal_request, @urgent_signal}, [
        :evict,
        timeout: {2, :second}
      ])

    run_blocking_activities(activity_payload, @activity_count)

    case await_result do
      {:ok, %{state: :requested}} -> admit_signal(@urgent_signal)
      _ -> :ok
    end

    run_blocking_activities(activity_payload, @activity_count)
    :ok
  end

  def run_blocking_activities(payload, activity_count) do
    for _ <- 1..activity_count do
      %{state: :completed} = start_activity(EchoActivity, [payload, @activity_sleep], [:wait])
    end
  end

  def eviction_handler(%{}, {eviction_strategy, event_id}) do
    case await({:event, {event_id, :_, :_, :_}}) do
      {:noevent, :noevent} ->
        :ok

      {:ok, %{event_id: event_id, attributes: %{history_size_bytes: hsb}}} ->
        maybe_evict(eviction_strategy, hsb)
        eviction_handler(%{}, {eviction_strategy, event_id + 1})

      {:ok, %{event_id: event_id}} ->
        eviction_handler(%{}, {eviction_strategy, event_id + 1})
    end
  end

  def maybe_evict(:always, _history_size_bytes), do: do_evict()

  def maybe_evict(:custom, history_size_bytes) when history_size_bytes > @eviction_hsb,
    do: do_evict()

  def maybe_evict(_eviction_strategy, _history_size_bytes), do: :ok

  def do_evict() do
    case is_awaited({:signal, @urgent_signal}) do
      {true, %{state: :requested}} -> :ok
      _ -> evict_workflow()
    end
  end
end
