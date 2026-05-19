defmodule WorkflowTerminate do
  @external_resource "docs/workflow_terminate.md"
  @moduledoc TemporalSdk.Utils.Code.exdoc!("docs/workflow_terminate.md")

  @spec run() :: :temporal_sdk.workflow_result() | no_return()
  def run() do
    :workflow_eviction.maybe_attach_telemetry()

    {:ok, %{workflow_execution: we}} =
      TemporalSdk.start_workflow(:cluster_1, "default", WorkflowTerminate.Workflow)

    # Some other work simulated by Process.sleep/1
    Process.sleep(500)
    {:ok, %{}} = TemporalSdk.terminate_workflow(:cluster_1, we, reason: "test termination")
    {:ok, result} = TemporalSdk.await_workflow(:cluster_1, we)
    result
  end
end
