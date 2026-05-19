defmodule EvictionParallelHandler do
  @external_resource "docs/eviction_parallel_handler.md"
  @moduledoc TemporalSdk.Utils.Code.exdoc!("docs/eviction_parallel_handler.md")

  @urgent_signal "urgent_signal"

  @spec run(
          activity_payload_size :: pos_integer(),
          handle_eviction_strategy :: :always | :custom | :never | atom()
        ) :: :ok | no_return()
  def run(activity_payload_size, handle_eviction_strategy) do
    :workflow_eviction.maybe_attach_telemetry()

    {:ok, %{workflow_execution: we}} =
      TemporalSdk.start_workflow(:cluster_1, "default", EvictionParallelHandler.Workflow,
        input: [[activity_payload_size, Atom.to_string(handle_eviction_strategy)]]
      )

    Process.sleep(2_000)
    TemporalSdk.signal_workflow(:cluster_1, we, @urgent_signal)
    {:ok, {:completed, %{}}} = TemporalSdk.await_workflow(:cluster_1, we)
    :ok
  end
end
