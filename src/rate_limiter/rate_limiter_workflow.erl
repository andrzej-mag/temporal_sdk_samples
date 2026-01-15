-module(rate_limiter_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

-define(ACTIVITIES_COUNT, 10).

execute(_Context, _Input) ->
    Activities =
        [
            start_activity(rate_limiter_activity, [Count], [{task_queue, "limited_tq"}])
         || Count <- lists:seq(1, ?ACTIVITIES_COUNT)
        ],
    wait_all(Activities).
