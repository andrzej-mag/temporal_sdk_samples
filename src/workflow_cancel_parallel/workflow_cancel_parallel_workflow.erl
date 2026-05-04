-module(workflow_cancel_parallel_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2,
    cancelation_handler/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

-define(ACTIVITIES_COUNT, 10).
-define(ACTIVITY_INTERVAL, 1_000).

execute(_Context, _Input) ->
    start_execution(cancelation_handler),
    [
        start_activity(echo_activity, [[~"Hello World."], I * ?ACTIVITY_INTERVAL], [
            {heartbeat_timeout, 1_000}
        ])
     || I <- lists:seq(1, ?ACTIVITIES_COUNT)
    ].

cancelation_handler(_Context, _Input) ->
    case await({cancel_request}) of
        {ok, #{state := requested}} ->
            cancel_workflow_execution([[cancelation_cleanup()]]);
        {noevent, noevent} ->
            complete_workflow_execution([[~"Workflow cancel request event not received."]])
    end.

cancelation_cleanup() ->
    OpenActivities = select_index([
        {
            {{activity, '$1'}, #{state => '$2'}},
            [
                {'orelse', {'=:=', '$2', cmd}, {'=:=', '$2', scheduled}, {'=:=', '$2', started}}
            ],
            ['$1']
        }
    ]),
    % eqwalizer:ignore
    [cancel_activity({activity, A}) || A <- OpenActivities],
    CleanupActivity = start_activity(workflow_cancel_parallel_activity, [OpenActivities]),
    case wait(CleanupActivity) of
        #{state := completed} -> ~"Cleanup successful.";
        #{} -> ~"Cleanup failed."
    end.
