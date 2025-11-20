-module(saga).

% elp:ignore W0012 W0040
-moduledoc {file, "../../docs/saga.md"}.

-export([
    start/0
]).

start() -> temporal_sdk:start_workflow(cluster_1, "default", saga_workflow, [wait]).
