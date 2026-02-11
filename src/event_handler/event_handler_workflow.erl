-module(event_handler_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).
-export([
    event_iterator/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

execute(_Context, _Input) ->
    start_execution(event_iterator, 1),
    start_activity(echo_activity, []),
    start_activity(echo_activity, [[], 5_000]),
    ok.

event_iterator(#{}, EventId) ->
    case await({event, {EventId, '_', '_', '_'}}) of
        {noevent, noevent} ->
            io:fwrite("NOEVENT~n", []);
        {ok, #{event_id := EventId, type := Type}} ->
            io:fwrite("~b: ~p~n", [EventId, Type]),
            event_iterator(#{}, EventId + 1)
    end.
