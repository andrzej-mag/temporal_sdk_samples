-module(activity_heartbeat).

% elp:ignore W0012 W0040
-moduledoc {file, "../../docs/activity_heartbeat.md"}.

-export([
    start/1,
    stage_cancelation_time/1,
    stage_duration/1
]).

-define(STAGE_DURATIONS, [3_000, 4_000, 5_000]).
-define(STAGE_CANCELATION_TIMES, [1_000, 5_000, 10_000]).

-spec start(CancelationStage :: pos_integer()) ->
    {temporal_sdk:start_workflow_ret(), temporal_sdk:workflow_result()}
    | no_return().
start(CancelationStage) when is_integer(CancelationStage), CancelationStage > 0 ->
    % eqwalizer:ignore incompatible_types
    temporal_sdk:start_workflow(cluster_1, "default", activity_heartbeat_workflow, [
        wait, {input, [CancelationStage]}
    ]).

-doc false.
stage_cancelation_time(Stage) -> lists:nth(Stage, ?STAGE_CANCELATION_TIMES).

-doc false.
stage_duration(Stage) -> lists:nth(Stage, ?STAGE_DURATIONS).
