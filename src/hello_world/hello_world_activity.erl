-module(hello_world_activity).

% elp:ignore W0012 W0040
-moduledoc false.

-export([execute/2]).

-include_lib("temporal_sdk/include/activity.hrl").

execute(_Context, [[String]]) -> [[string:uppercase(String)]].
