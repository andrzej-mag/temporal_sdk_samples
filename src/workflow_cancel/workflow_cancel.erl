-module(workflow_cancel).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/workflow_cancel.md"}.

-export([
    start/0
]).

start() ->
    {ok, #{workflow_execution := WE}} = temporal_sdk:start_workflow(
        cluster_1, "default", workflow_cancel_workflow
    ),
    %% Some other work simulated by timer:sleep/1
    timer:sleep(1_000),
    {ok, #{}} = temporal_sdk_service:cancel_workflow(cluster_1, WE, [{reason, ~"CANCEL ALL"}]),
    temporal_sdk:await_workflow(cluster_1, WE).
