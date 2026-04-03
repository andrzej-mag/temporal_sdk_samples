-module(awaitable_event_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

execute(_Context, _Input) ->
    AStart = start_activity(echo_activity, [[~"Activity completed."]], [
        {task_queue, "awaitable_event"},
        {awaitable_event, start}
    ]),
    case await(AStart, 1000) of
        {noevent, #{}} -> io:fwrite("WARN: Activity NOT started within 1000 msec timeout.~n", []);
        {ok, #{}} -> io:fwrite("INFO: Activity started within 1000 msec timeout.~n", [])
    end,
    % eqwalizer:ignore
    AClose = setelement(1, AStart, activity),
    #{state := completed, result := [[R]]} = wait(AClose),
    io:fwrite("~p~n", [R]).
