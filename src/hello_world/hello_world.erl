-module(hello_world).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/hello_world.md"}.

-export([
    start/0
]).

start() ->
    temporal_sdk:start_workflow(cluster_1, "default", hello_world_workflow, [
        wait, {input, ["from Temporal"]}
    ]).
