defmodule WorkflowCancelParallel do
  @external_resource "docs/workflow_cancel_parallel.md"
  @moduledoc TemporalSdk.Utils.exdoc!("docs/workflow_cancel_parallel.md")

  @spec run(cancellation_delay :: pos_integer()) :: :temporal_sdk.workflow_result() | no_return()
  def run(cancellation_delay) when is_integer(cancellation_delay) do
    {:ok, %{workflow_execution: we}} =
      TemporalSdk.start_workflow(:cluster_1, "default", WorkflowCancelParallel.Workflow)

    Process.sleep(cancellation_delay)
    {:ok, %{}} = TemporalSdk.cancel_workflow(:cluster_1, we)
    {:ok, result} = TemporalSdk.await_workflow(:cluster_1, we)
    result
  end
end
