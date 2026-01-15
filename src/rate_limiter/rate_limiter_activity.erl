-module(rate_limiter_activity).

% elp:ignore W0012 W0040
-moduledoc false.

-export([execute/2]).

-include_lib("temporal_sdk/include/activity.hrl").

execute(_Context, [ActivityCount]) when is_integer(ActivityCount) ->
    io:fwrite("Executing activity number ~b~n", [ActivityCount]),
    timer:sleep(1000),
    ["ok"].
