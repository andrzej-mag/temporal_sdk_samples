-module(mutable_marker).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/mutable_marker.md"}.

-export([
    run/0
]).

run() ->
    temporal_sdk:start_workflow(cluster_1, "default", mutable_marker_workflow, [
        {workflow_task_timeout, 1_000}
    ]),
    ok.
