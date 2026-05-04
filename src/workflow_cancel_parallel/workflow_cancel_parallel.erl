-module(workflow_cancel_parallel).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/workflow_cancel_parallel.md"}.

-export([
    run/1
]).

-spec run(CancellationDelay :: pos_integer()) -> temporal_sdk:workflow_result() | no_return().
run(CancellationDelay) when is_integer(CancellationDelay) ->
    {ok, #{workflow_execution := WE}} = temporal_sdk:start_workflow(
        cluster_1, "default", workflow_cancel_parallel_workflow
    ),
    timer:sleep(CancellationDelay),
    {ok, #{}} = temporal_sdk:cancel_workflow(cluster_1, WE),
    {ok, Result} = temporal_sdk:await_workflow(cluster_1, WE),
    Result.
