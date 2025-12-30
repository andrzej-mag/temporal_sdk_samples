-module(saga_activity_deposit).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2,
    handle_heartbeat/1,
    handle_cancel/1
]).

-include_lib("temporal_sdk/include/activity.hrl").

execute(_Context, _Input) ->
    timer:sleep(100),
    ["deposit"].

handle_heartbeat(_Context) -> heartbeat.

handle_cancel(#{cancel_requested := true}) -> {cancel, ["details"]};
handle_cancel(_Context) -> ignore.
