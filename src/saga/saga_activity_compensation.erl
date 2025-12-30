-module(saga_activity_compensation).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/activity.hrl").

execute(_Context, [CompensationState, _TransferDetails]) ->
    io:fwrite("Compensation activity started with:~n    ~p~n~n", [CompensationState]),
    timer:sleep(100),
    ["compensation"].
