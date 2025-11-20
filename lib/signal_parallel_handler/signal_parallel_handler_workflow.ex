defmodule SignalParallelHandler.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @ping_signal "ping"
  @kill_signal "kill"
  @report_signal "report"

  @impl true
  def execute(context, []), do: execute(context, [0])

  def execute(context, [count]) when is_integer(count) and count >= 0 do
    # Temporal requires a "real" task running during workflow execution.
    # Since signals are not tasks, timer is used as a Temporal task surrogate in this task-less WF.
    %{workflow_info: %{workflow_execution_timeout_msec: we_timeout}} = context
    await_open_before_close(false)
    start_timer(2 * we_timeout)

    set_info(count, info_id: :signal_count)
    start_execution(:report_signal_handler)
    start_execution(:signal_counter_handler, count)
  end

  def report_signal_handler(_context, _input) do
    case await_all(signal_request: @report_signal, info: :signal_count) do
      {:ok, [%{}, count]} ->
        IO.puts("Ping signals count: #{count}")
        admit_signal(@report_signal, [:wait])
        report_signal_handler(%{}, [])

      _ ->
        :ok
    end
  end

  def signal_counter_handler(_context, count) when count < 10_000 do
    case await_one(signal_request: @kill_signal, signal_request: @ping_signal) do
      {:ok, [:noevent, ping_signal_data]} ->
        new_count = count + count_requested_signals(ping_signal_data)
        admit_signal(@ping_signal, [:wait])

        case is_awaited({:suggest_continue_as_new}) do
          {false, _} ->
            set_info(new_count, info_id: :signal_count)
            signal_counter_handler(%{}, new_count)

          {true, _} ->
            continue_as_new_workflow("default", __MODULE__, input: [new_count])
        end

      {:ok, [%{state: :requested}, _]} ->
        complete_workflow_execution([count])
    end
  end

  def signal_counter_handler(_context, _count),
    do: fail_workflow_execution(%{message: "Overflow."})

  defp count_requested_signals(%{state: :requested, history: h}),
    do: count_requested_signals_history(h, 1)

  defp count_requested_signals(%{state: :requested}), do: 1

  defp count_requested_signals_history([%{state: :requested} | th], acc),
    do: count_requested_signals_history(th, acc + 1)

  defp count_requested_signals_history(_, acc), do: acc
end
