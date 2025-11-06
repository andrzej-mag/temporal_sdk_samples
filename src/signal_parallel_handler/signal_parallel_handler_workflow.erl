-module(signal_parallel_handler_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2,
    report_signal_handler/2,
    signal_counter_handler/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

-include("signal_parallel_handler.hrl").

execute(Context, []) ->
    execute(Context, [0]);
execute(Context, [Count]) when is_integer(Count), Count >= 0 ->
    %% Temporal requires a "real" task running during workflow execution.
    %% Since signals are not tasks, timer is used as a Temporal task surrogate in this task-less WF.
    #{workflow_info := #{workflow_execution_timeout_msec := WETimeout}} = Context,
    await_open_before_close(false),
    start_timer(2 * WETimeout),

    set_info(Count, [{info_id, signal_count}]),
    start_execution(report_signal_handler),
    start_execution(signal_counter_handler, Count).

%% "report" signal logic is implemented as a separate parallel handler for educational purposes.
report_signal_handler(_Context, _Input) ->
    case await_all([{signal_request, ?REPORT_SIGNAL}, {info, signal_count}]) of
        {ok, [#{}, Count]} ->
            io:fwrite("Ping signals count: ~kp~n", [Count]),
            admit_signal(?REPORT_SIGNAL, [wait]),
            report_signal_handler(#{}, []);
        _ ->
            ok
    end.

signal_counter_handler(_Context, Count) when Count < 10_000 ->
    case await_one([{signal_request, ?KILL_SIGNAL}, {signal_request, ?PING_SIGNAL}]) of
        {ok, [noevent, PingSignalData]} ->
            NewCount = Count + count_requested_signals(PingSignalData),
            admit_signal(?PING_SIGNAL, [wait]),
            case is_awaited({suggest_continue_as_new}) of
                {false, _} ->
                    set_info(NewCount, [{info_id, signal_count}]),
                    signal_counter_handler(#{}, NewCount);
                {true, _} ->
                    continue_as_new_workflow("default", ?MODULE, [{input, [NewCount]}])
            end;
        {ok, [#{state := requested}, _]} ->
            complete_workflow_execution([Count])
    end;
signal_counter_handler(_Context, _Count) ->
    fail_workflow_execution(#{message => "Overflow."}).

count_requested_signals(#{state := requested, history := H}) ->
    count_requested_signals_history(H, 1);
count_requested_signals(#{state := requested}) ->
    1.

count_requested_signals_history([#{state := requested} | TH], Acc) ->
    count_requested_signals_history(TH, Acc + 1);
count_requested_signals_history(_, Acc) ->
    Acc.
