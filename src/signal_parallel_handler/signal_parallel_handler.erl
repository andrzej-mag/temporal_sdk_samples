-module(signal_parallel_handler).

% elp:ignore W0012 W0040
-moduledoc """
Example signal parallel handler.

Example workflow execution performs following tasks:
  * count `"ping"` signals,
  * complete workflow on `"kill"` signal,
  * report current `"ping"` signals count on `"report"` signal,
  * continue as new workflow execution on `suggest_continue_as_new` event,
  * fail workflow on `"ping"` signals count exceeding 10_000.

To prevent Temporal server overload, `"ping"` signals are dispatched at 100 millisecond intervals.

Run this example with:
```erlang
signal_parallel_handler:start().
```
""".

-export([
    start/0
]).

-include("signal_parallel_handler.hrl").

-define(SIGNAL_COUNTER_WId, "signal_counter").
-define(SIGNAL_COUNTER_WE, #{workflow_id => ?SIGNAL_COUNTER_WId}).

start() ->
    temporal_sdk:start_workflow(
        ?CLUSTER,
        "default",
        signal_parallel_handler_workflow,
        [{workflow_id, ?SIGNAL_COUNTER_WId}, {workflow_execution_timeout, {1, hour}}]
    ),
    send_signals(3_000).

send_signals(Count) when is_integer(Count), Count > 0 ->
    case temporal_sdk:get_workflow_state(?CLUSTER, ?SIGNAL_COUNTER_WE) of
        {ok, running} ->
            send_signal(?PING_SIGNAL),
            case Count rem 100 of
                0 -> send_signal(?REPORT_SIGNAL);
                _ -> ok
            end,
            timer:sleep(100),
            send_signals(Count - 1);
        _ ->
            ok
    end;
send_signals(0) ->
    timer:sleep(1_000),
    send_signal(?KILL_SIGNAL).

send_signal(Signal) ->
    temporal_sdk_service:signal_workflow(?CLUSTER, ?SIGNAL_COUNTER_WE, Signal).
