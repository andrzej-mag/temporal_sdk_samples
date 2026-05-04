defmodule WorkflowCancelParallel.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @activities_count 10
  @activity_interval 1_000

  @impl true
  def execute(_context, _input) do
    start_execution(:cancelation_handler)

    for i <- 1..@activities_count do
      start_activity(:echo_activity, [["Hello World."], i * @activity_interval],
        heartbeat_timeout: 1_000
      )
    end
  end

  def cancelation_handler(_context, _input) do
    case await({:cancel_request}) do
      {:ok, %{state: :requested}} ->
        cancel_workflow_execution([[cancelation_cleanup()]])

      {:noevent, :noevent} ->
        complete_workflow_execution([["Workflow cancel request event not received."]])
    end
  end

  defp cancelation_cleanup() do
    open_activities =
      select_index([
        {
          {{:activity, :"$1"}, %{:state => :"$2"}},
          [
            {:orelse, {:"=:=", :"$2", :cmd}, {:"=:=", :"$2", :scheduled},
             {:"=:=", :"$2", :started}}
          ],
          [:"$1"]
        }
      ])

    for a <- open_activities, do: cancel_activity({:activity, a})
    cleanup_activity = start_activity(WorkflowCancelParallel.Activity, [open_activities])

    case wait(cleanup_activity) do
      %{state: :completed} -> "Cleanup successful."
      %{} -> "Cleanup failed."
    end
  end
end
