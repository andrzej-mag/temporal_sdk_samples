-module(awaitable_event_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

execute(_Context, _Input) ->
    {activity_start, AId} =
        AStart = start_activity(echo_activity, [[~"Activity completed."]], [
            {task_queue, "awaitable_event"},
            {awaitable_event, start}
        ]),
    {AwaitStatus, #{}} = await(AStart, 1_000),
    #{is_replaying := IsReplaying} = workflow_info(),
    case {IsReplaying, AwaitStatus} of
        {true, _} ->
            ok;
        {false, noevent} ->
            io:fwrite(
                "WARN: Activity not started within 1000 msec timeout or nonexistent activity.~n", []
            );
        {false, ok} ->
            io:fwrite("INFO: Activity started within 1000 msec timeout.~n", [])
    end,
    AClose = {activity, AId},
    #{state := completed, result := [[AR]]} = wait(AClose),
    io:fwrite("~p~n", [AR]).
