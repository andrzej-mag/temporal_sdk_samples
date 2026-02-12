-module(workflow_benchmark).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/workflow_benchmark.md"}.

-export([
    start/2
]).

-define(PARALLEL_COUNT, 100).
-define(LOOP_COUNT, 5).
-define(TASK_QUEUE, "workflow_benchmark").

-spec start(RequestEagerExecution :: boolean(), PoolSize :: pos_integer()) -> ok | no_return().
start(RequestEagerExecution, PoolSize) ->
    case temporal_sdk_worker:is_started(cluster_1, workflow, ?MODULE) of
        true -> temporal_sdk_worker:terminate(cluster_1, workflow, ?MODULE);
        false -> ok
    end,
    {ok, #{}} = temporal_sdk_worker:start(cluster_1, workflow, [
        {worker_id, ?MODULE}, {task_queue, ?TASK_QUEUE}, {task_poller_pool_size, PoolSize}
    ]),
    start(RequestEagerExecution, self(), 1, 0).

start(RequestEagerExecution, Pid, LoopId, Acc) when LoopId =< ?LOOP_COUNT ->
    StartTime = erlang:system_time(nanosecond),
    [
        spawn(fun() -> run_workflow(RequestEagerExecution, Pid, RunId) end)
     || RunId <- lists:seq(1, ?PARALLEL_COUNT)
    ],
    case receive_results([]) of
        ok ->
            Duration = erlang:system_time(nanosecond) - StartTime,
            WPS = round(?PARALLEL_COUNT / Duration * 1.0E9),
            io:fwrite("Run ~b of ~b. Workflows per second: ~b.~n", [LoopId, ?LOOP_COUNT, WPS]),
            start(RequestEagerExecution, Pid, LoopId + 1, Acc + WPS);
        Err ->
            Err
    end;
start(_RequestEagerExecution, _Pid, _LoopId, WPS) ->
    temporal_sdk_worker:terminate(cluster_1, workflow, ?MODULE),
    io:fwrite("Average workflows per second: ~b.~n", [round(WPS / ?LOOP_COUNT)]).

run_workflow(RequestEagerExecution, Pid, RunId) ->
    case do_run_workflow(RequestEagerExecution, RunId) of
        {#{}, {completed, #{result := [RunId]}}} ->
            Pid ! {completed, RunId};
        {#{}, {completed, #{result := R}}} ->
            Pid !
                {error, #{reason => "Invalid workflow result.", expected => RunId, received => R}};
        Err ->
            Pid ! {error, Err}
    end.

do_run_workflow(true, RunId) ->
    temporal_sdk:start_workflow(cluster_1, ?TASK_QUEUE, workflow_benchmark_workflow, [
        wait,
        {input, [RunId]},
        request_eager_execution,
        {eager_worker_id, ?MODULE}
    ]);
do_run_workflow(false, RunId) ->
    temporal_sdk:start_workflow(cluster_1, ?TASK_QUEUE, workflow_benchmark_workflow, [
        wait,
        {input, [RunId]}
    ]).

receive_results(Acc) when length(Acc) < ?PARALLEL_COUNT ->
    receive
        {completed, RunId} -> receive_results([RunId | Acc]);
        Err -> Err
    after 10_000 -> timeout
    end;
receive_results(Acc) ->
    case lists:seq(1, ?PARALLEL_COUNT) =:= lists:sort(Acc) of
        true -> ok;
        false -> integrity_error
    end.
