-module(child_workflow_child_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

execute(_Context, [[~"cancel"]]) ->
    cancel_workflow_execution([[~"Test child WF cancellation."]]);
execute(_Context, [[~"fail"]]) ->
    fail_workflow_execution([{message, "Test child WF failure."}]);
execute(_Context, [[~"invalid"]]) ->
    complete_workflow_execution([12345]);
execute(_Context, _Input) ->
    #{result := R} = start_activity(echo_activity, [[~"from temporal"]], [wait]),
    complete_workflow_execution(R).
