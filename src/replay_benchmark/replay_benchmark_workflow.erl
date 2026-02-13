-module(replay_benchmark_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

-define(TASK_COUNT, 1_000).

execute(#{is_replaying := IsR1}, [[TaskType]]) when is_binary(TaskType) ->
    Seq = lists:seq(1, ?TASK_COUNT),
    StartTime = erlang:system_time(nanosecond),
    case run_tasks(TaskType, Seq) of
        true -> ok;
        false -> fail_workflow_execution([{message, "Run tasks integrity check failure."}])
    end,
    TPS = round(?TASK_COUNT / (erlang:system_time(nanosecond) - StartTime) * 1_000_000_000),
    #{is_replaying := IsR2} = workflow_info(),
    %% Additional activity is started exclusively to ensure proper IsR2 value:
    wait(start_activity(echo_activity, [[]])),
    case {IsR1, IsR2} of
        {false, false} ->
            io:fwrite("EXECUTION. Tasks per second: ~b.~n~n", [TPS]),
            throw("Force workflow replay.");
        {true, true} ->
            io:fwrite("~nREPLAY. Tasks per second: ~b.~n", [TPS]);
        {true, false} ->
            io:fwrite("~nPARTIAL REPLAY.~n", [])
    end.

%% Automatic awaitables id generation is relatively costly operation so we manually assign awaitable
%% ids to improve performance.
run_tasks(~"activity", Seq) ->
    run_tasks(~"regular_execution_activity", Seq);
run_tasks(~"regular_execution_activity", Seq) ->
    Tasks = [
        start_activity(echo_activity, [I], [{activity_id, integer_to_list(I)}])
     || I <- Seq
    ],
    Seq =:= lists:map(fun(#{result := [R]}) -> R end, wait_all(Tasks));
run_tasks(~"eager_execution_activity", Seq) ->
    Tasks = [
        start_activity(echo_activity, [I], [eager_execution, {activity_id, integer_to_list(I)}])
     || I <- Seq
    ],
    Seq =:= lists:map(fun(#{result := [R]}) -> R end, wait_all(Tasks));
run_tasks(~"marker", Seq) ->
    Tasks = [
        record_marker(fun() -> [I] end, [{marker_name, integer_to_list(I)}])
     || I <- Seq
    ],
    Seq =:= lists:map(fun(#{value := [R]}) -> R end, wait_all(Tasks));
run_tasks(~"recorded_marker", Seq) ->
    Tasks = [
        record_marker(fun() -> [I] end, [
            {marker_name, integer_to_list(I)}, {awaitable_event, close}
        ])
     || I <- Seq
    ],
    Seq =:= lists:map(fun(#{value := [R]}) -> R end, wait_all(Tasks)).
