-module(activity_heartbeat_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

execute(_Context, [CancelationStage]) when is_integer(CancelationStage), CancelationStage > 0 ->
    A = start_activity(activity_heartbeat_activity, [], [{heartbeat_timeout, 1_000}]),
    case CancelationStage =< 3 of
        true ->
            %% Some other work is simulated by Temporal timer.
            start_timer(activity_heartbeat:stage_cancelation_time(CancelationStage), [wait]),
            #{state := canceled, details := D} = cancel_activity(A, [wait]),
            set_workflow_result(D);
        false ->
            wait(A),
            set_workflow_result(["activity closed"])
    end.
