defmodule WorkflowCancel.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @impl true
  def execute(_context, _input) do
    a = start_activity(EchoActivity, [["Hello World."], 5_000], heartbeat_timeout: 1_000)

    case await_one([{:cancel_request}, a]) do
      {:ok, [%{state: :requested, cause: "CANCEL ALL"}, %{state: as}]}
      when as === :cmd or as === :scheduled or as === :started ->
        cancel_activity(a)
        cancel_workflow_execution([["CANCEL ALL requested."]])

      {:ok, [%{state: :requested, cause: _}, %{}]} ->
        cancel_workflow_execution([["Workflow execution canceled."]])

      {:ok, [:noevent, %{}]} ->
        set_workflow_result([["Workflow execution not canceled."]])
    end
  end
end
