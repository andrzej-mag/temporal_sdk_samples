-module(activity_heartbeat_activity).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2,
    handle_heartbeat/1,
    handle_cancel/1
]).

-include_lib("temporal_sdk/include/activity.hrl").

%% Work performed during each execution stage is simulated with `timer:sleep/1`.
execute(_Context, _Input) ->
    %% stage s1
    set_data(#{current_stage => s1}),
    timer:sleep(activity_heartbeat:stage_duration(1)),
    %% stage s2
    set_data(#{current_stage => s2}),
    timer:sleep(activity_heartbeat:stage_duration(2)),
    %% stage s3
    set_data(#{current_stage => s3}),
    timer:sleep(activity_heartbeat:stage_duration(3)),
    ["activity completed"].

handle_heartbeat(#{
    cancel_requested := CancelRequested,
    data := #{current_stage := Stage},
    last_heartbeat := [#{current_stage := Stage} = LastHeartbeat]
}) ->
    #{Stage := HeartbeatCount} = LastHeartbeat,
    NH = LastHeartbeat#{Stage := HeartbeatCount + 1, cancel_requested := CancelRequested},
    io:fwrite("HB: ~kp~n", [NH]),
    {heartbeat, [NH]};
handle_heartbeat(#{
    cancel_requested := CancelRequested,
    data := #{current_stage := Stage},
    last_heartbeat := [#{} = LastHeartbeat]
}) ->
    NH = LastHeartbeat#{current_stage => Stage, Stage => 1, cancel_requested := CancelRequested},
    io:fwrite("HB: ~kp~n", [NH]),
    {heartbeat, [NH]};
handle_heartbeat(#{
    cancel_requested := CancelRequested,
    data := #{current_stage := Stage}
}) ->
    NH = #{current_stage => Stage, Stage => 1, cancel_requested => CancelRequested},
    io:fwrite("HB: ~kp~n", [NH]),
    {heartbeat, [NH]}.

handle_cancel(#{cancel_requested := false}) ->
    ignore;
handle_cancel(#{data := #{current_stage := s1}}) ->
    io:fwrite("cancelation: Cancelation in stage s1.~n"),
    {cancel, ["stage s1 cancelation"]};
handle_cancel(#{data := #{current_stage := s2}}) ->
    io:fwrite("cancelation: Ignore cancelation in stage s2.~n"),
    ignore;
handle_cancel(#{data := #{current_stage := s3}}) ->
    io:fwrite("cancelation: Cleanup and cancelation in stage s3.~n"),
    {cancel, ["stage s3 cancelation"]}.
