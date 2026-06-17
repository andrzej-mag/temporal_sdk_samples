defmodule WorkflowEviction.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @activity_count 3
  @activity_sleep 500
  @urgent_signal "urgent_signal"
  @eviction_hsb 500_000

  @impl true
  def execute(_context, [[activity_payload_size, handle_eviction_strategy]])
      when is_integer(activity_payload_size) and is_binary(handle_eviction_strategy) do
    set_info(String.to_existing_atom(handle_eviction_strategy),
      info_id: :handle_eviction_strategy
    )

    activity_payload = String.duplicate("X", activity_payload_size)
    run_blocking_activities(activity_payload, @activity_count)
    await_result = await({:signal_request, @urgent_signal}, [:evict, timeout: {2, :second}])
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

  @impl true
  def handle_eviction(%{workflow_info: %{history_size_bytes: hsb}}, _poll_idle_time) do
    case is_awaited_all([{:info, :handle_eviction_strategy}, {:signal, @urgent_signal}]) do
      {false, [:noevent, _]} ->
        throw("Required <handle_eviction_strategy> info not set.")

      {false, [handle_eviction_strategy, :noevent]} ->
        do_handle_eviction(handle_eviction_strategy, hsb)

      {true, [handle_eviction_strategy, %{state: :admitted}]} ->
        do_handle_eviction(handle_eviction_strategy, hsb)

      {_, _} ->
        :ignore
    end
  end

  def do_handle_eviction(:always, _history_size_bytes), do: :evict
  def do_handle_eviction(:never, _history_size_bytes), do: :ignore
  def do_handle_eviction(_handle_eviction_strategy, hsb) when hsb > @eviction_hsb, do: :evict
  def do_handle_eviction(_handle_eviction_strategy, _history_size_bytes), do: :ignore
end
