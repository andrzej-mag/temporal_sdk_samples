-module(signal_simple_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

-define(CANCEL_ACTIVITY_SIGNAL, "cancel_activity").

execute(_Context, _Input) ->
    A = start_activity(echo_activity, [[], 3_000], [{heartbeat_timeout, 1_000}]),
    case await_one([{signal_request, ?CANCEL_ACTIVITY_SIGNAL}, A], {10, second}) of
        {ok, [#{}, #{state := S}]} when S =:= cmd; S =:= scheduled; S =:= started ->
            cancel_activity(A),
            set_workflow_result(["Cancel requested. Activity canceled."]);
        {ok, [noevent, #{}]} ->
            set_workflow_result(["Cancel not requested. Activity closed."]);
        %% For the sake of educational completeness:
        {ok, [#{}, noevent]} ->
            set_workflow_result(["Cancel requested. Activity not started."]);
        {noevent, _} ->
            set_workflow_result(["Cancel not requested. Activity not started."])
    end.
