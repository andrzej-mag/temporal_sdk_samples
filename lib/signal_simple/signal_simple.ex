defmodule SignalSimple do
  @external_resource "docs/signal_simple.md"
  @moduledoc TemporalSdk.Utils.exdoc!("docs/signal_simple.md")

  @cluster :cluster_1
  @cancel_activity_signal "cancel_activity"

  def start_then_signal() do
    {:ok, %{workflow_execution: we}} =
      TemporalSdk.start_workflow(@cluster, "default", SignalSimple.Workflow)

    Process.sleep(1_000)
    TemporalSdk.signal_workflow(@cluster, we, @cancel_activity_signal)
    TemporalSdk.wait_workflow(@cluster, we)
  end

  def start_with_signal() do
    TemporalSdk.start_workflow(@cluster, "default", SignalSimple.Workflow, [
      :wait,
      signal_name: @cancel_activity_signal
    ])
  end
end
