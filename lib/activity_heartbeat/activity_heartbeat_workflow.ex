defmodule ActivityHeartbeat.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @impl true
  def execute(_context, [cancelation_stage])
      when is_integer(cancelation_stage) and cancelation_stage > 0 do
    a = start_activity(ActivityHeartbeat.Activity, [], heartbeat_timeout: 1_000)

    case cancelation_stage <= 3 do
      true ->
        # Some other work is simulated by Temporal timer.
        start_timer(ActivityHeartbeat.stage_cancelation_time(cancelation_stage), [:wait])
        %{state: :canceled, details: d} = cancel_activity(a, [:wait])
        set_workflow_result(d)

      false ->
        wait(a)
        set_workflow_result(["activity closed"])
    end
  end
end
