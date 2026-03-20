-module(mutable_marker_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

-define(MUTABLE_MARKER, "mutable_marker").

execute(_Context, _Input) ->
    %% Don't run side effects inside workflow implementation
    mock_env(),

    #{result := [A1R]} = start_activity(echo_activity, [[~"first_activity"]], [wait]),
    #{mutations_count := MC, value := [MV]} =
        record_env(?MUTABLE_MARKER, [wait, {mutable, #{mutations_limit => 5}}]),
    io:fwrite("Mutable Marker - mutations count: ~b, marker value: ~b.~n", [MC, MV]),
    A2 = start_activity(echo_activity, [[~"second_activity", MV], 3_000]),

    %% Following code is used to emulate worker node restart and environmental variable mutation
    start_timer(1000, [wait]),
    case MC < 3 of
        true ->
            await_open_before_close(false),
            terminate_executor();
        _ ->
            ok
    end,

    #{result := [A2R]} = wait(A2),
    complete_workflow_execution([A1R, A2R]).

mock_env() ->
    os:putenv(?MUTABLE_MARKER, integer_to_list(erlang:unique_integer([positive, monotonic]))).
