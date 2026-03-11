-module(determinism_check_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

execute(_Context, [[~"echo_activity"]]) -> start_activity(echo_activity, [[]]);
execute(_Context, [[~"hello_activity"]]) -> start_activity(hello_world_activity, [[""]]);
execute(_Context, [[~"rand_uniform"]]) -> record_rand_uniform();
execute(_Context, [[~"uuid4"]]) -> record_uuid4();
execute(_Context, _Input) -> ok.
