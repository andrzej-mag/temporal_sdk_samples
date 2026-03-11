-module(determinism_check).
-behaviour(temporal_sdk_api_workflow_check).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/determinism_check.md"}.

-export([
    replay/3
]).
-export([
    is_deterministic/4
]).

-spec replay(CheckMod :: module(), Input :: binary(), ReplayInput :: binary()) ->
    temporal_sdk:replay_json_ret().
replay(CheckMod, Input, ReplayInput) ->
    % eqwalizer:ignore
    temporal_sdk:replay_task(
        cluster_1,
        "default",
        determinism_check_workflow,
        determinism_check_workflow,
        [
            {start_workflow_opts, [{input, [[Input]]}]},
            {replay_workflow_opts, [
                {worker_opts, [
                    {disable_telemetry, true},
                    {task_settings, [{deterministic_check_mod, CheckMod}]}
                ]},
                {task_overwrites, [{input, [[ReplayInput]]}]}
            ]}
        ]
    ).

%% -------------------------------------------------------------------------------------------------
%% behaviour implementation

-doc false.
is_deterministic(
    {ActualAwaitable, #{event_id := EventId, state := ActualState}},
    {ReceivedAwaitable, #{event_id := EventId, state := ReceivedState}},
    _ActualCommand,
    _ReceivedHistoryEvent
) ->
    test_state(ActualState, ReceivedState) andalso
        test_awaitable(ActualAwaitable, ReceivedAwaitable);
is_deterministic(_ActualAwaitable, _ReceivedAwaitable, _ActualCommand, _ReceivedHistoryEvent) ->
    false.

test_state(cmd, _State) -> true;
test_state(started, canceled) -> true;
test_state(State, State) -> true;
test_state(_ActualState, _ReceivedState) -> false.

test_awaitable({A}, {A}) -> true;
test_awaitable({A, _}, {A, _}) -> true;
test_awaitable({A, AT, _}, {A, AT, _}) -> true;
test_awaitable(_ActualAwaitable, _ReceivedAwaitable) -> false.
