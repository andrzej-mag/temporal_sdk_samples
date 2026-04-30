-module(signal_simple).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/signal_simple.md"}.

-export([
    start_then_signal/0,
    start_with_signal/0
]).

-define(CLUSTER, cluster_1).
-define(CANCEL_ACTIVITY_SIGNAL, "cancel_activity").

start_then_signal() ->
    {ok, #{workflow_execution := WE}} =
        temporal_sdk:start_workflow(?CLUSTER, "default", signal_simple_workflow),
    timer:sleep(1_000),
    temporal_sdk:signal_workflow(?CLUSTER, WE, ?CANCEL_ACTIVITY_SIGNAL),
    temporal_sdk:wait_workflow(?CLUSTER, WE).

start_with_signal() ->
    temporal_sdk:start_workflow(?CLUSTER, "default", signal_simple_workflow, [
        wait, {signal_name, ?CANCEL_ACTIVITY_SIGNAL}
    ]).
