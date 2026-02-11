-module(workflow_benchmark).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/workflow_benchmark.md"}.

-export([
    start/0
]).

-define(PARALLEL_COUNT, 100).
-define(LOOP_COUNT, 5).

start() ->
    start(self(), 1, 0).

start(Pid, LoopId, Acc) when LoopId =< ?LOOP_COUNT ->
    StartTime = erlang:system_time(nanosecond),
    [spawn(fun() -> run_workflow(Pid, RunId) end) || RunId <- lists:seq(1, ?PARALLEL_COUNT)],
    case receive_results([]) of
        ok ->
            Duration = erlang:system_time(nanosecond) - StartTime,
            WPS = round(?PARALLEL_COUNT / Duration * 1.0E9),
            io:fwrite("Run ~b of ~b. Workflows per second: ~b.~n", [LoopId, ?LOOP_COUNT, WPS]),
            start(Pid, LoopId + 1, Acc + WPS);
        Err ->
            Err
    end;
start(_Pid, _LoopId, WPS) ->
    io:fwrite("Average workflows per second: ~b.~n", [round(WPS / ?LOOP_COUNT)]).

run_workflow(Pid, RunId) ->
    case
        temporal_sdk:start_workflow(cluster_1, "default", workflow_benchmark_workflow, [
            wait, {input, [RunId]}
        ])
    of
        {#{}, {completed, #{result := [RunId]}}} ->
            Pid ! {completed, RunId};
        {#{}, {completed, #{result := R}}} ->
            Pid !
                {error, #{reason => "Invalid workflow result.", expected => RunId, received => R}};
        Err ->
            Pid ! {error, Err}
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
