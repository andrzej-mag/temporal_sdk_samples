defmodule ChildWorkflow do
  @external_resource "docs/child_workflow.md"
  @moduledoc File.read!("docs/child_workflow.md")

  @spec run(child_workflow_outcome :: :complete | :cancel | :fail | :invalid | atom()) ::
          :temporal_sdk.workflow_result() | no_return()
  def run(child_workflow_outcome) when is_atom(child_workflow_outcome) do
    r =
      TemporalSdk.start_workflow(:cluster_1, "default", ChildWorkflow.Workflow, [
        :wait,
        input: [[:erlang.atom_to_binary(child_workflow_outcome)]]
      ])

    case r do
      {s, _} when s === :error or S === :ok -> throw("Unexpected result.")
      {_start_workflow_ret, workflow_result} -> workflow_result
    end
  end
end
