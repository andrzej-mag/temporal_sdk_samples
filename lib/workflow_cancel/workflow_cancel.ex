defmodule WorkflowCancel do
  @external_resource "docs/workflow_cancel.md"
  @moduledoc TemporalSdk.Utils.exdoc!("docs/workflow_cancel.md")

  @spec run(cancellation_type :: :cancel_all | :cancel_await | :cancel_abandon | atom()) ::
          :temporal_sdk.workflow_result() | no_return()
  def run(cancellation_type) do
    {:ok, %{workflow_execution: we}} =
      TemporalSdk.start_workflow(:cluster_1, "default", WorkflowCancel.Workflow)

    # Some other work simulated by Process.sleep/1
    Process.sleep(1_000)

    {:ok, %{}} =
      TemporalSdk.Service.cancel_workflow(:cluster_1, we,
        reason: :erlang.atom_to_binary(cancellation_type)
      )

    {:ok, result} = TemporalSdk.await_workflow(:cluster_1, we)
    result
  end
end
