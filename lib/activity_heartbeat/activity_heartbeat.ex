defmodule ActivityHeartbeat do
  @external_resource "docs/activity_heartbeat.md"
  @moduledoc TemporalSdk.Utils.exdoc!("docs/activity_heartbeat.md")

  @stage_durations [3_000, 4_000, 5_000]
  @stage_cancelation_times [1_000, 5_000, 10_000]

  @spec start(cancelation_stage :: pos_integer()) ::
          {:temporal_sdk.start_workflow_ret(), :temporal_sdk.workflow_result()}
          | no_return()
  def start(cancelation_stage) when is_integer(cancelation_stage) and cancelation_stage > 0,
    do:
      TemporalSdk.start_workflow(:cluster_1, "default", ActivityHeartbeat.Workflow, [
        :wait,
        input: [cancelation_stage]
      ])

  @doc false
  def stage_cancelation_time(stage), do: Enum.at(@stage_cancelation_times, stage - 1)

  @doc false
  def stage_duration(stage), do: Enum.at(@stage_durations, stage - 1)
end
