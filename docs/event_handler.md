Handling [Temporal events](https://docs.temporal.io/workflow-execution/event) with parallel execution
sample.

Sample implements a workflow that executes `event_iterator` parallel execution and two `m:echo_activity`
activities.
The first workflow activity completes immediately, while the second activity sleeps for 5 seconds before
completion.
`event_iterator` parallel execution handles events by printing the Temporal event ID and event type to
the terminal if there is an event, and prints "NOEVENT" if there are no more events.

5 seconds sleep time in the second activity execution is introduced to demonstrate how Temporal adds
activity events to the [event history](https://docs.temporal.io/workflow-execution/event#event-history).
When an activity is started,
[activity events](https://docs.temporal.io/workflow-execution/event#activity-events)
are added to the event history.
First, an `ActivityTaskScheduled` event occurs, specifically `EVENT_TYPE_ACTIVITY_TASK_SCHEDULED`
events 5 and 6 in the example run code snippet below.
When an activity task is completed, the activity task worker reports the completion to the Temporal service,
and the Temporal service adds `ActivityTaskStarted` and `ActivityTaskCompleted` events to the event history.
In our example, this corresponds to events number 7 and 8 for the first activity, and events number
12 and 13 for the second activity.

Additionally, it should be noted that the `EVENT_TYPE_WORKFLOW_EXECUTION_COMPLETED` event is missing
from the events list produced by the `event_iterator`, as this event is not replayed during normal
workflow execution.

Example run:

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> TemporalSdk.start_workflow(:cluster_1, "default", EventHandler.Workflow)
{:ok,
 %{
   started: true,
   request_id: ~c"cluster_1-Elixir.EventHandler.Workflow-f8cf5c07-acc7-4dbc-81ec-09bed2844294",
   workflow_execution: %{
     workflow_id: ~c"Elixir.EventHandler.Workflow/9be58c03-e895-4a90-9bab-6ca6a6f6cc4a",
     run_id: "019c47db-eb6b-7ba1-b857-cdf54462d133"
   }
 }}
1: EVENT_TYPE_WORKFLOW_EXECUTION_STARTED
2: EVENT_TYPE_WORKFLOW_TASK_SCHEDULED
3: EVENT_TYPE_WORKFLOW_TASK_STARTED
4: EVENT_TYPE_WORKFLOW_TASK_COMPLETED
5: EVENT_TYPE_ACTIVITY_TASK_SCHEDULED
6: EVENT_TYPE_ACTIVITY_TASK_SCHEDULED
7: EVENT_TYPE_ACTIVITY_TASK_STARTED
8: EVENT_TYPE_ACTIVITY_TASK_COMPLETED
9: EVENT_TYPE_WORKFLOW_TASK_SCHEDULED
10: EVENT_TYPE_WORKFLOW_TASK_STARTED
# a 5-second delay occurs here
11: EVENT_TYPE_WORKFLOW_TASK_COMPLETED
12: EVENT_TYPE_ACTIVITY_TASK_STARTED
13: EVENT_TYPE_ACTIVITY_TASK_COMPLETED
14: EVENT_TYPE_WORKFLOW_TASK_SCHEDULED
15: EVENT_TYPE_WORKFLOW_TASK_STARTED
NOEVENT
# not replayed:
# 16: "WorkflowTaskCompleted"
# 17: "WorkflowExecutionCompleted"
```

Sample source:
[lib/event_handler](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/event_handler)

### Erlang

```erlang
1> temporal_sdk:start_workflow(cluster_1, "default", event_handler_workflow).
{ok,#{started => true,
      request_id =>
          "cluster_1-event_handler_workflow-91066688-94d3-4fb5-b9c3-27df3ffc7b3a",
      workflow_execution =>
          #{workflow_id =>
                "event_handler_workflow/33ba0923-ec15-4929-aeb1-f98c2d00ed52",
            run_id => <<"019c47a8-76ad-739d-9041-77cac104c641">>}}}
1: 'EVENT_TYPE_WORKFLOW_EXECUTION_STARTED'
2: 'EVENT_TYPE_WORKFLOW_TASK_SCHEDULED'
3: 'EVENT_TYPE_WORKFLOW_TASK_STARTED'
4: 'EVENT_TYPE_WORKFLOW_TASK_COMPLETED'
5: 'EVENT_TYPE_ACTIVITY_TASK_SCHEDULED'
6: 'EVENT_TYPE_ACTIVITY_TASK_SCHEDULED'
7: 'EVENT_TYPE_ACTIVITY_TASK_STARTED'
8: 'EVENT_TYPE_ACTIVITY_TASK_COMPLETED'
9: 'EVENT_TYPE_WORKFLOW_TASK_SCHEDULED'
10: 'EVENT_TYPE_WORKFLOW_TASK_STARTED'
% a 5-second delay occurs here
11: 'EVENT_TYPE_WORKFLOW_TASK_COMPLETED'
12: 'EVENT_TYPE_ACTIVITY_TASK_STARTED'
13: 'EVENT_TYPE_ACTIVITY_TASK_COMPLETED'
14: 'EVENT_TYPE_WORKFLOW_TASK_SCHEDULED'
15: 'EVENT_TYPE_WORKFLOW_TASK_STARTED'
NOEVENT
% not replayed:
% 16: "WorkflowTaskCompleted"
% 17: "WorkflowExecutionCompleted"
```

Sample source:
[src/event_handler](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/event_handler)

<!-- tabs-close -->
