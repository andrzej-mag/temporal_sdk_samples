defmodule ParallelExecution do
  @external_resource "docs/parallel_execution.md"
  @moduledoc TemporalSdk.Utils.Code.exdoc!("docs/parallel_execution.md")

  @spec run({String.t(), String.t(), String.t(), String.t()}) ::
          :temporal_sdk.workflow_result() | no_return()
  def run({_, _, _, _} = input) do
    {:ok, _start_workflow_ret, workflow_result} =
      TemporalSdk.start_workflow(:cluster_1, "default", ParallelExecution.Workflow, [
        :await,
        input: [Tuple.to_list(input)]
      ])

    workflow_result
  end
end
