-module(workflow_cancel_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

execute(_Context, _Input) ->
    A = start_activity(echo_activity, [[~"Hello World."], 5_000], [{heartbeat_timeout, 1_000}]),
    case await_any([{cancel_request}, A]) of
        {ok, [#{state := requested, cause := ~"cancel_all" = C}, #{state := AS}]} when
            AS =:= cmd; AS =:= scheduled; AS =:= started
        ->
            cancel_activity(A),
            cancel_workflow_execution([[C]]);
        {ok, [#{state := requested, cause := ~"cancel_all" = C}, #{}]} ->
            cancel_workflow_execution([[C]]);
        {ok, [#{state := requested, cause := ~"cancel_await" = C}, #{}]} ->
            cancel_workflow_execution([[C]]);
        {ok, [#{state := requested, cause := ~"cancel_abandon" = C}, #{}]} ->
            await_open_before_close(false),
            cancel_workflow_execution([[C]]);
        {ok, [#{state := requested, cause := C}, #{}]} ->
            fail_workflow_execution([
                {message, "Unrecognized cancel_workflow reason."}, {stack_trace, C}
            ]);
        {ok, [noevent, #{}]} ->
            complete_workflow_execution([[~"Workflow execution cancel not requested."]])
    end.
