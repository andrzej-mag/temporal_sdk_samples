defmodule ChildWorkflow.ChildWorkflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @impl true

  def execute(_context, [["cancel"]]),
    do: cancel_workflow_execution([["Test child WF cancellation."]])

  def execute(_context, [["fail"]]),
    do: fail_workflow_execution(message: "Test child WF failure.")

  def execute(_context, [["invalid"]]),
    do: complete_workflow_execution([12345])

  def execute(_context, _input) do
    %{result: r} = start_activity(EchoActivity, [["from temporal"]], [:wait])
    complete_workflow_execution(r)
  end
end
