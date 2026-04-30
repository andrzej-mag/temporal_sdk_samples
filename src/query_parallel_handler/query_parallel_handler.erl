-module(query_parallel_handler).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/query_parallel_handler.md"}.

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
    QR = temporal_sdk:query_workflow(Cluster, WE, ?PROGRESS_QUERY),
    inspect_query_response(QR, lists:concat(["progress after ", Count, " sec"])),
    timer:sleep(1_000),
    run_query(Cluster, WE, Count + 1);
run_query(Cluster, WE, _Count) ->
    temporal_sdk:await_workflow(Cluster, WE),
    QR = temporal_sdk:query_workflow(Cluster, WE, ?PROGRESS_QUERY),
    inspect_query_response(QR, "closed WF query").

inspect_query_response({ok, #{query_result := R}}, Header) ->
    io:fwrite("~s: ~p~n", [Header, R]);
inspect_query_response(Err, Header) ->
    io:fwrite("~s: ~p~n", [Header, Err]).
