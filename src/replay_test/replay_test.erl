-module(replay_test).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/replay_test.md"}.

-export([
    replay_from_file/0,
    replay_from_file_nde/0,
    replay_from_json/0,
    create_json/0
]).

replay_from_file() ->
    temporal_sdk:replay_file(
        cluster_1, replay_test_workflow, "src/replay_test/replay_test_workflow.json"
    ).

replay_from_file_nde() ->
    temporal_sdk:replay_file(
        cluster_1, hello_world_workflow, "src/replay_test/replay_test_workflow.json"
    ).

replay_from_json() ->
    {#{workflow_execution := WE}, _} =
        temporal_sdk:start_workflow(cluster_1, "default", replay_test_workflow, [
            wait, {input, [[~b"from Temporal"]]}
        ]),
    {ok, _History, Json} = temporal_sdk:get_workflow_history(cluster_1, WE, [await_all, json]),
    temporal_sdk:replay_json(cluster_1, replay_test_workflow, Json).

create_json() ->
    {#{workflow_execution := WE}, _} =
        temporal_sdk:start_workflow(cluster_1, "default", replay_test_workflow, [wait]),
    temporal_sdk:get_workflow_history(cluster_1, WE, [await_all, history_file]).
