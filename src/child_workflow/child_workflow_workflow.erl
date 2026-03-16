-module(child_workflow_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

execute(_Context, Input) ->
    Activity = start_activity(hello_world_activity, [[~"hello world"]]),
    ChildWorkflow = start_child_workflow("default", child_workflow_child_workflow, [{input, Input}]),
    case wait_all([Activity, ChildWorkflow]) of
        [#{state := completed, result := [[AR]]}, #{state := completed, result := [[CR]]}] when
            is_binary(AR), is_binary(CR)
        ->
            complete_workflow_execution([[AR, CR]]);
        [#{state := completed, result := AD}, #{state := completed, result := CD}] ->
            fail_workflow_execution([
                {message, "Invalid data."},
                {stack_trace, #{activity_data => AD, child_workflow_data => CD}}
            ]);
        [#{state := AS}, #{state := CS}] ->
            fail_workflow_execution([
                {message, "Error."},
                {stack_trace, #{activity_state => AS, child_workflow_state => CS}}
            ])
    end.
