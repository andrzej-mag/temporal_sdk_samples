defmodule SignalParallelHandler do
  @external_resource "docs/signal_parallel_handler.md"
  @moduledoc TemporalSdk.Utils.exdoc!("docs/signal_parallel_handler.md")

  @cluster :cluster_1
  @ping_signal "ping"
  @kill_signal "kill"
  @report_signal "report"
  @signal_counter_wid "signal_counter"
  @signal_counter_we %{workflow_id: @signal_counter_wid}

  def start() do
    TemporalSdk.start_workflow(
      @cluster,
      "default",
      SignalParallelHandler.Workflow,
      workflow_id: @signal_counter_wid,
      workflow_execution_timeout: {1, :hour}
    )

    send_signals(3_000)
  end

  defp send_signals(count) when is_integer(count) and count > 0 do
    case TemporalSdk.get_workflow_state(@cluster, @signal_counter_we) do
      {:ok, :running} ->
        send_signal(@ping_signal)

        case rem(count, 100) do
          0 -> send_signal(@report_signal)
          _ -> :ok
        end

        Process.sleep(100)
        send_signals(count - 1)

      _ ->
        :ok
    end
  end

  defp send_signals(0) do
    Process.sleep(1_000)
    send_signal(@kill_signal)
  end

  defp send_signal(signal),
    do: TemporalSdk.signal_workflow(@cluster, @signal_counter_we, signal)
end
