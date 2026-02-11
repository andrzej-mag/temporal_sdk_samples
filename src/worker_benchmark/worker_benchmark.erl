-module(worker_benchmark).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/worker_benchmark.md"}.

-export([
    start/0
]).

-define(PARALLEL_COUNT, 100).
-define(LOOP_COUNT, 5).
-define(SLEEP_TIME, 2_000).

start() ->
    start(self(), 1, 0).

start(Pid, LoopId, Acc) when LoopId =< ?LOOP_COUNT ->
    StartTime = erlang:system_time(nanosecond),
    [spawn(fun() -> run_worker(Pid, RunId) end) || RunId <- lists:seq(1, ?PARALLEL_COUNT)],
    case receive_results([]) of
        ok ->
            Duration = erlang:system_time(nanosecond) - StartTime,
            WPS = round(?PARALLEL_COUNT / Duration * 1.0E9),
            io:fwrite("Run ~b of ~b. Workers per second: ~b.~n", [LoopId, ?LOOP_COUNT, WPS]),
            timer:sleep(?SLEEP_TIME),
            start(Pid, LoopId + 1, Acc + WPS);
        Err ->
            Err
    end;
start(_Pid, _LoopId, WPS) ->
    io:fwrite("Average workers per second: ~b.~n", [round(WPS / ?LOOP_COUNT)]).

run_worker(Pid, RunId) ->
    %% The same task queue is used across consecutive runs to avoid violating Temporal server task
    %% queue RPS limits.
    TQ = integer_to_list(RunId),
    maybe
        {ok, #{worker_id := WorkerId}} ?=
            temporal_sdk_worker:start(cluster_1, activity, [
                {task_queue, TQ}, {task_poller_pool_size, 1}
            ]),
        true ?= temporal_sdk_worker:is_started(cluster_1, activity, WorkerId),
        ok ?= temporal_sdk_worker:terminate(cluster_1, activity, WorkerId),
        Pid ! {completed, RunId}
    else
        Err -> Pid ! {error, Err}
    end.

receive_results(Acc) when length(Acc) < ?PARALLEL_COUNT ->
    receive
        {completed, RunId} -> receive_results([RunId | Acc]);
        Err -> Err
    after 70_000 -> timeout
    end;
receive_results(Acc) ->
    case lists:seq(1, ?PARALLEL_COUNT) =:= lists:sort(Acc) of
        true -> ok;
        false -> integrity_error
    end.
