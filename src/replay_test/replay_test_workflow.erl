-module(replay_test_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

execute(_Context, _Input) ->
    start_timer(1),
    start_activity(echo_activity, [[~"hello world"]]),
    record_uuid4().
