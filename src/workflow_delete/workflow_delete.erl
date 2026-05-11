-module(workflow_delete).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/workflow_delete.md"}.

-export([
    run/0
]).

-spec run() -> ok | no_return().
run() ->
    workflow_eviction:maybe_attach_telemetry(),
    {ok, #{workflow_execution := WE}} = temporal_sdk:start_workflow(
        cluster_1, "default", workflow_terminate_workflow
    ),
    %% Sleep commands are used to mitigate Temporal server eventual consistency
    timer:sleep(500),
    io:fwrite("WF execution state before deletion:~n  ~kp~n~n", [
        temporal_sdk:get_workflow_state(cluster_1, WE)
    ]),
    {ok, #{}} = temporal_sdk:delete_workflow(cluster_1, WE),
    timer:sleep(500),
    io:fwrite("WF execution state after deletion:~n  ~kp~n~n", [
        temporal_sdk:get_workflow_state(cluster_1, WE)
    ]).
