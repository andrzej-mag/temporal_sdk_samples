-module(workflow_terminate).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/workflow_terminate.md"}.

-export([
    run/0
]).

-spec run() -> temporal_sdk:workflow_result() | no_return().
run() ->
    workflow_eviction:maybe_attach_telemetry(),
    {ok, #{workflow_execution := WE}} = temporal_sdk:start_workflow(
        cluster_1, "default", workflow_terminate_workflow
    ),
    %% Some other work simulated by timer:sleep/1
    timer:sleep(500),
    {ok, #{}} = temporal_sdk:terminate_workflow(cluster_1, WE, [{reason, "test termination"}]),
    {ok, Result} = temporal_sdk:await_workflow(cluster_1, WE),
    Result.
