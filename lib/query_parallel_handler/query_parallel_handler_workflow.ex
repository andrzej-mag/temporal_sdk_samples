defmodule QueryParallelHandler.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @progress_query <<"get_progress">>

  # Main simplifications assumed for the sake of educational code brevity:
  # * auxiliary hypothetical workflow tasks like initialization or cleanup are mimicked with timers,
  # * activities inputs and results are omitted.
  @impl true
  def execute(_context, _input) do
    # init
    set_info(:init, info_id: :progress)
    start_execution(:progress_query_handler)
    cleanup_execution = start_execution(:cleanup)
    start_timer(2_000, [:wait])
    # run
    set_info(:undefined, info_id: :progress)
    a0 = start_activity(:echo_activity, [[], 6_000], activity_id: :stage_0)
    start_activity(:echo_activity, [[], 2_000], [:wait, activity_id: :stage_1])
    start_activity(:echo_activity, [[], 2_000], [:wait, activity_id: :stage_2])
    # wait async activities
    set_info(:wait_async, info_id: :progress)
    wait(a0)
    # cleanup
    wait(cleanup_execution)
    # finalize
    set_info(:finalize, info_id: :progress)
    start_timer(2_000, [:wait])
  end

  def cleanup(_context, _input) do
    case wait_all(activity: :stage_0, activity: :stage_1, activity: :stage_2) do
      [%{state: completed}, %{state: completed}, %{state: completed}] ->
        set_info(:cleanup, info_id: :progress)
        start_timer(2_000, [:wait])

      _ ->
        set_info(:cleanup_and_compensation, info_id: :progress)
        start_timer(20_000, [:wait])
    end
  end

  def progress_query_handler(_context, _input) do
    case await({:query_request, @progress_query}) do
      {:ok, _} ->
        case is_awaited_any(info: :progress, activity: :stage_2, activity: :stage_1) do
          {true, [:undefined, %{}, _]} ->
            do_respond_progress_query(:stage_2)

          {true, [:undefined, :noevent, %{}]} ->
            do_respond_progress_query(:stage_1)

          {true, [p, _, _]} ->
            do_respond_progress_query(p)

          {false, _} ->
            do_respond_progress_query(:undefined)
        end

      {:noevent, _} ->
        :ok
    end
  end

  defp do_respond_progress_query(answer) do
    respond_query({:query, @progress_query}, [:wait, answer: ["open", answer]])
    progress_query_handler(%{}, [])
  end

  @impl true
  def handle_query(history, %{query_type: @progress_query}) do
    {_event_id, event_type, _event_data, _ignored_event_data} = List.last(history)
    %{answer: ["closed", event_type]}
  end
end
