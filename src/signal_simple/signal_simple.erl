-module(signal_simple).

% elp:ignore W0012 W0040
-moduledoc """
Simple signaling example.

Example run:
```erlang
1> signal_simple:start_then_signal().
{completed,#{result => ["Activity canceled."],
             workflow_task_completed_event_id => 17,
             new_execution_run_id => <<>>}}
2> signal_simple:start_with_signal().
{#{started => true,
   request_id =>
       "cluster_1-signal_simple_workflow-7ba9e83a-21a2-4265-9c73-da9b4c7eb226",
   workflow_execution =>
       #{workflow_id =>
             "signal_simple_workflow/2178b61b-1e19-4b20-89cb-846bed756bdb",
         run_id => <<"a141867c-4670-4650-b24a-146d38bd3b28">>}},
 {completed,#{result => ["Activity canceled."],
              workflow_task_completed_event_id => 13,
              new_execution_run_id => <<>>}}}
```
""".

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
    temporal_sdk_service:signal_workflow(?CLUSTER, WE, ?CANCEL_ACTIVITY_SIGNAL),
    temporal_sdk:wait_workflow(?CLUSTER, WE).

start_with_signal() ->
    temporal_sdk:start_workflow(?CLUSTER, "default", signal_simple_workflow, [
        wait, {signal_name, ?CANCEL_ACTIVITY_SIGNAL}
    ]).
