defmodule ChildWorkflow.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @impl true

  def execute(_context, input) do
    activity = start_activity(HelloWorld.Activity, [["hello world"]])
    child_workflow = start_child_workflow("default", ChildWorkflow.ChildWorkflow, input: input)

    case wait_all([activity, child_workflow]) do
      [%{state: :completed, result: [[ar]]}, %{state: :completed, result: [[cr]]}]
      when is_binary(ar) and is_binary(cr) ->
        complete_workflow_execution([[ar, cr]])

      [%{state: :completed, result: ad}, %{state: :completed, result: cd}] ->
        fail_workflow_execution(
          message: "Invalid data.",
          stack_trace: %{activity_data: ad, child_workflow_data: cd}
        )

      [%{state: as}, %{state: cs}] ->
        fail_workflow_execution(
          message: "Error.",
          stack_trace: %{activity_state: as, child_workflow_state: cs}
        )
    end
  end
end
