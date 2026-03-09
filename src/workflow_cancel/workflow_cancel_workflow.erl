-module(workflow_cancel_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

execute(_Context, _Input) ->
    A = start_activity(echo_activity, [[~b"Hello World."], 5_000], [{heartbeat_timeout, 1_000}]),
    case await_one([{cancel_request}, A]) of
        {ok, [#{state := requested, cause := ~"CANCEL ALL"}, #{state := AS}]} when
            AS =:= cmd; AS =:= scheduled; AS =:= started
        ->
            cancel_activity(A),
            cancel_workflow_execution([[~"CANCEL ALL requested."]]);
        {ok, [#{state := requested, cause := _}, #{}]} ->
            cancel_workflow_execution([[~"Workflow execution canceled."]]);
        {ok, [noevent, #{}]} ->
            set_workflow_result([[~"Workflow execution not canceled."]])
    end.
