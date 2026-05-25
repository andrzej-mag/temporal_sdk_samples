-module(parallel_execution_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).
-export([
    execution_parallel/2,
    execution_nested/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

execute(_Context, [[I1, I2, I3, I4]]) ->
    %% Parallel executions require unique execution_id.
    %% When calling start_execution/3, by default, execution_id is set to the function name, hence we
    %% assign a unique execution_id manually here to fulfill uniqueness requirement.
    E1 = start_execution(execution_parallel, [I1, I2], [{execution_id, e1}]),
    E2 = start_execution(execution_parallel, [I3, I4], [{execution_id, e2}]),
    [#{result := E1R}, #{result := E2R}] = wait_all([E1, E2]),
    set_workflow_result([lists:flatten([E1R, E2R])]).

execution_parallel(_Context, [I1, I2]) ->
    A1 = start_activity(echo_activity, [I1]),
    A2 = start_activity(echo_activity, [I2]),
    [#{result := A1R}, #{result := A2R}] = wait_all([A1, A2]),
    %% Unique execution_id can be automatically generated with awaitable_id.
    #{result := R} = start_execution(execution_nested, [A1R, A2R], [wait, {awaitable_id, e_nested}]),
    R.

execution_nested(_Context, [I1, I2]) ->
    A1 = start_activity(hello_world_activity, [I1]),
    A2 = start_activity(hello_world_activity, [I2]),
    [#{result := [[A1R]]}, #{result := [[A2R]]}] = wait_all([A1, A2]),
    [A1R, A2R].
