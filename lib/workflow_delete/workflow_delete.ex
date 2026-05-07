defmodule WorkflowDelete do
  @external_resource "docs/workflow_delete.md"
  @moduledoc TemporalSdk.Utils.exdoc!("docs/workflow_delete.md")

  @spec run() :: :ok | no_return()
  def run() do
    {:ok, %{workflow_execution: we}} =
      TemporalSdk.start_workflow(:cluster_1, "default", WorkflowTerminate.Workflow)

    # Sleep commands are used to mitigate Temporal server eventual consistency
    Process.sleep(500)

    IO.puts("""
    WF execution state before deletion:
      #{TemporalSdk.get_workflow_state(:cluster_1, we) |> inspect()}
    """)

    {:ok, %{}} = TemporalSdk.delete_workflow(:cluster_1, we)
    Process.sleep(500)

    IO.puts("""
    WF execution state after deletion:
      #{TemporalSdk.get_workflow_state(:cluster_1, we) |> inspect()}
    """)
  end
end
