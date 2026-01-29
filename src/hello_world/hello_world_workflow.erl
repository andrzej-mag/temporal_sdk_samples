-module(hello_world_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

execute(_Context, Input) ->
    A1 = start_activity(hello_world_activity, [[~b"hello"]]),
    A2 = start_activity(hello_world_activity, [[~b"world"]]),
    [#{result := A1Result}, #{result := A2Result}] = wait_all([A1, A2]),
    io:fwrite("~s ~s ~s~n~n", [A1Result, A2Result, Input]).
