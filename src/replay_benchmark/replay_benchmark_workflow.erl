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
    Duration = (erlang:system_time(nanosecond) - StartTime),
    #{is_replaying := IsR2, event_id := EId} = workflow_info(),
    TPS = round(?TASK_COUNT / Duration * 1_000_000_000),
    EPS = round(EId / Duration * 1_000_000_000),
    %% Additional activity is started exclusively to ensure proper IsR2 value:
    #{result := [123.456]} = start_activity(echo_activity, [123.456], [wait]),
    case {IsR1, IsR2} of
        {false, false} ->
            io:fwrite("EXECUTION: ~b commands per second, ~p events per second.~n~n", [TPS, EPS]),
            throw("Force workflow replay.");
        {true, true} ->
            io:fwrite("~nREPLAY: ~b commands per second, ~b events per second.~n", [TPS, EPS]);
        {true, false} ->
            io:fwrite("~nMIXED EXECUTION & REPLAY: not benchmarked.~n", [])
    end.

%% Automatic awaitables id generation is relatively costly operation so we manually assign awaitable
%% id or name to improve performance.
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
run_tasks(~"activity_await_cmd", Seq) ->
    Tasks = [
        start_activity(echo_activity, [I], [
            {activity_id, integer_to_list(I)},
            {awaitable_event, cmd}
        ])
     || I <- Seq
    ],
    lists:all(
        fun
            (#{state := cmd}) -> true;
            (_) -> false
        end,
        wait_all(Tasks)
    );
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
