defmodule SignalSimple.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @cancel_activity_signal "cancel_activity"

  @impl true
  def execute(_context, _input) do
    a = start_activity(:echo_activity, [[], 3_000], heartbeat_timeout: 1_000)

    case await_any([{:signal_request, @cancel_activity_signal}, a], {10, :second}) do
      {:ok, [%{}, %{state: s}]} when s == :cmd or s == :scheduled or s == :started ->
        cancel_activity(a)
        set_workflow_result(["Cancel requested. Activity canceled."])

      {:ok, [:noevent, %{}]} ->
        set_workflow_result(["Cancel not requested. Activity closed."])

      # For the sake of educational completeness:
      {:ok, [%{}, :noevent]} ->
        set_workflow_result(["Cancel requested. Activity not started."])

      {:noevent, _} ->
        set_workflow_result(["Cancel not requested. Activity not started."])
    end
  end
end
