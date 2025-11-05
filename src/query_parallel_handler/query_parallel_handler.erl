-module(query_parallel_handler).

% elp:ignore W0012 W0040
-moduledoc """
Example query parallel handler.

Workflow defined in this example runs tasks in a multiple distinctive workflow execution stages:
init, stage_1, stage_2, wait_async, cleanup and finalize.
Workflow execution is queried every second with `~"get_progress"` query.
When workflow execution is in open state, progress query parallel handler responds with
workflow state `"open"` and current workflow execution stage.
When workflow execution is closed, conventional query handle callback function responds with
workflow state `"closed"` and last workflow history event type.
Query responses are echoed to the terminal.

Example run:
```erlang
1> query_parallel_handler:start().
progress after 0 sec: ["open",<<"init">>]
progress after 1 sec: ["open",<<"init">>]
progress after 2 sec: ["open",<<"stage_1">>]
progress after 3 sec: ["open",<<"stage_1">>]
progress after 4 sec: ["open",<<"stage_2">>]
progress after 5 sec: ["open",<<"stage_2">>]
progress after 6 sec: ["open",<<"wait_async">>]
progress after 7 sec: ["open",<<"wait_async">>]
progress after 8 sec: ["open",<<"cleanup">>]
progress after 9 sec: ["open",<<"cleanup">>]
progress after 10 sec: ["open",<<"finalize">>]
progress after 11 sec: ["open",<<"finalize">>]
progress after 12 sec: ["closed",
                        <<"EVENT_TYPE_WORKFLOW_EXECUTION_COMPLETED">>]
closed WF query: ["closed",<<"EVENT_TYPE_WORKFLOW_EXECUTION_COMPLETED">>]
ok
```

REMAINDER: Temporal query requests are not persisted in the workflow history hence they are
nondeterministic and cannot be used in a workflow execution branching.
Following example commands will fail workflow execution or behave unexpectedly:
```erlang
await({query_request, "test_query"}, 10_000)

await_one([{query_request, "test_query"}, {marker, uuid4, test_marker}])

case await({query, "test_query"}) of
	{ok, _} -> start_timer(1_000);
	_ -> start_activity(echo_activity, [])
end
```
""".

-export([
    start/0
]).

-define(PROGRESS_QUERY, ~"get_progress").

start() ->
    Cluster = cluster_1,
    {ok, #{workflow_execution := WE}} =
        temporal_sdk:start_workflow(Cluster, "default", query_parallel_handler_workflow),
    run_query(Cluster, WE, 0).

run_query(Cluster, WE, Count) when Count < 13 ->
    QR = temporal_sdk_service:query_workflow(Cluster, WE, ?PROGRESS_QUERY),
    inspect_query_response(QR, lists:concat(["progress after ", Count, " sec"])),
    timer:sleep(1_000),
    run_query(Cluster, WE, Count + 1);
run_query(Cluster, WE, _Count) ->
    temporal_sdk:await_workflow(Cluster, WE),
    QR = temporal_sdk_service:query_workflow(Cluster, WE, ?PROGRESS_QUERY),
    inspect_query_response(QR, "closed WF query").

inspect_query_response({ok, #{query_result := R}}, Header) ->
    io:fwrite("~s: ~p~n", [Header, R]);
inspect_query_response(Err, Header) ->
    io:fwrite("~s: ~p~n", [Header, Err]).
