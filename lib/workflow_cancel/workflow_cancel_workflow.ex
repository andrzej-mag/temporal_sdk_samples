defmodule WorkflowCancel.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @impl true
  def execute(_context, _input) do
    a = start_activity(EchoActivity, [["Hello World."], 5_000], heartbeat_timeout: 1_000)

    case await_one([{:cancel_request}, a]) do
      {:ok, [%{state: :requested, cause: "cancel_all" = c}, %{state: as}]}
      when as === :cmd or as === :scheduled or as === :started ->
        cancel_activity(a)
        cancel_workflow_execution([[c]])

      {:ok, [%{state: :requested, cause: "cancel_all" = c}, %{}]} ->
        cancel_workflow_execution([[c]])

      {:ok, [%{state: :requested, cause: "cancel_await" = c}, %{}]} ->
        cancel_workflow_execution([[c]])

      {:ok, [%{state: :requested, cause: "cancel_abandon" = c}, %{}]} ->
        await_open_before_close(false)
        cancel_workflow_execution([[c]])

      {:ok, [%{state: :requested, cause: c}, %{}]} ->
        fail_workflow_execution(message: "Unrecognized cancel_workflow reason.", stack_trace: c)

      {:ok, [:noevent, %{}]} ->
        complete_workflow_execution([["Workflow execution cancel not requested."]])
    end
  end
end
