defmodule WorkflowCancel do
  @external_resource "docs/workflow_cancel.md"
  @moduledoc File.read!("docs/workflow_cancel.md")

  def start() do
    {:ok, %{workflow_execution: we}} =
      TemporalSdk.start_workflow(:cluster_1, "default", WorkflowCancel.Workflow)

    # Some other work simulated by Process.sleep/1
    Process.sleep(1_000)
    {:ok, %{}} = TemporalSdk.Service.cancel_workflow(:cluster_1, we, reason: "CANCEL ALL")
    TemporalSdk.await_workflow(:cluster_1, we)
  end
end
