-module(replay_benchmark).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/replay_benchmark.md"}.

-export([
    start/1
]).

-spec start(
    TaskType ::
        activity
        | regular_execution_activity
        | eager_execution_activity
        | activity_await_cmd
        | marker
        | recorded_marker
) ->
    ok.
start(TaskType) ->
    temporal_sdk:start_workflow(cluster_1, "default", replay_benchmark_workflow, [
        wait, {input, [[atom_to_binary(TaskType)]]}
    ]),
    ok.
