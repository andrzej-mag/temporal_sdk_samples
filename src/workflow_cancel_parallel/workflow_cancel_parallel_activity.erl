-module(workflow_cancel_parallel_activity).

% elp:ignore W0012 W0040
-moduledoc false.

-export([execute/2]).

-include_lib("temporal_sdk/include/activity.hrl").

execute(_Context, [Activities]) when is_list(Activities) ->
    io:fwrite("Running cleanup activity. Canceled activities count: ~b.~n", [length(Activities)]),
    [~"ok"].
