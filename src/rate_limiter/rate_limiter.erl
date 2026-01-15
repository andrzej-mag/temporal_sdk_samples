-module(rate_limiter).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/rate_limiter.md"}.

-export([
    start_worker/0,
    terminate_worker/0,
    get_worker_concurrency_limit/0,
    set_worker_concurrency_limit/1,
    start/0
]).

-define(WORKER_ID, "limited_worker").

-define(FREQUENCY_LIMIT, 1_000).

start_worker() ->
    temporal_sdk_worker:start(
        cluster_1,
        activity,
        [
            {worker_id, ?WORKER_ID},
            {task_queue, "limited_tq"},
            {task_poller_pool_size, 1}
        ]
    ).

terminate_worker() ->
    temporal_sdk_worker:terminate(cluster_1, activity, ?WORKER_ID).

get_worker_concurrency_limit() ->
    case temporal_sdk_worker:get_limiter_config(cluster_1, activity, ?WORKER_ID) of
        {ok, #{limits := #{worker := #{activity_regular := {L, _}}}}} -> {ok, L};
        {ok, _} -> undefined;
        Err -> Err
    end.

set_worker_concurrency_limit(ConcurrencyLimit) when is_integer(ConcurrencyLimit) ->
    temporal_sdk_worker:set_limiter_config(
        cluster_1,
        activity,
        ?WORKER_ID,
        #{limits => #{worker => #{activity_regular => {ConcurrencyLimit, ?FREQUENCY_LIMIT}}}}
    ).

start() ->
    StartTime = erlang:system_time(millisecond),
    case temporal_sdk:start_workflow(cluster_1, "default", rate_limiter_workflow, [wait]) of
        {#{}, {completed, #{}}} ->
            Duration = erlang:system_time(millisecond) - StartTime,
            io:fwrite("Workflow completed in ~b msec.~n", [Duration]);
        Err ->
            Err
    end.
