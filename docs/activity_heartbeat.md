Activity heartbeating and selective cancelation example.

In this example workflow starts a single activity that can be canceled.
Activity execution has three stages `s1`, `s2` and `s3`.
Each activity stage takes some time to execute.
Activity execution can be canceled in stages `s1` and `s3` but not in stage `s2`.
Activity heartbeating provides a detailed history of activity stage execution,
which can be considered activity mini-metrics in the Temporal web UI.
Consecutive heartbeats sent to the Temporal server are echoed to the terminal.

Workflow execution can be started with `start/1` which takes a cancellation stage number as an
argument.
To skip activity cancelation step, cancelation stage number should be any integer greater than 3.

Example run output for activity cancelation request in stage 2 (HB heartbeats echoed every second):

<!-- tabs-open -->

### Elixir

```elixir
iex(1)> ActivityHeartbeat.start(2)
HB: %{cancel_requested: false, current_stage: :s1, s1: 1}
HB: %{cancel_requested: false, current_stage: :s1, s1: 2}
HB: %{cancel_requested: false, current_stage: :s1, s1: 3}
HB: %{cancel_requested: false, current_stage: :s2, s1: 3, s2: 1}
HB: %{cancel_requested: false, current_stage: :s2, s1: 3, s2: 2}
HB: %{cancel_requested: false, current_stage: :s2, s1: 3, s2: 3}
HB: %{cancel_requested: false, current_stage: :s2, s1: 3, s2: 4}
cancelation: Ignore cancelation in stage s2.
HB: %{cancel_requested: true, current_stage: :s2, s1: 3, s2: 5}
cancelation: Ignore cancelation in stage s2.
HB: %{cancel_requested: true, current_stage: :s3, s1: 3, s2: 5, s3: 1}
cancelation: Cleanup and cancelation in stage s3.
{%{
   started: true,
   request_id: ~c"cluster_1-Elixir.ActivityHeartbeat.Workflow-f7a69412-2537-468e-9a54-12372f2de997",
   workflow_execution: %{
     workflow_id: ~c"Elixir.ActivityHeartbeat.Workflow/f920b769-0446-416c-951a-327931d52e49",
     run_id: "019a91ea-c4d3-7e97-b74a-4f0f81de4441"
   }
 },
 {:completed,
  %{
    result: ["stage s3 cancelation"],
    workflow_task_completed_event_id: 16,
    new_execution_run_id: ""
  }}}
```

Sample source:
[lib/activity_heartbeat](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/activity_heartbeat)

### Erlang

```erlang
1> activity_heartbeat:start(2).
HB: #{cancel_requested => false,current_stage => s1,s1 => 1}
HB: #{cancel_requested => false,current_stage => s1,s1 => 2}
HB: #{cancel_requested => false,current_stage => s1,s1 => 3}
HB: #{cancel_requested => false,current_stage => s2,s1 => 3,s2 => 1}
HB: #{cancel_requested => false,current_stage => s2,s1 => 3,s2 => 2}
HB: #{cancel_requested => false,current_stage => s2,s1 => 3,s2 => 3}
HB: #{cancel_requested => false,current_stage => s2,s1 => 3,s2 => 4}
cancelation: Ignore cancelation in stage s2.
HB: #{cancel_requested => true,current_stage => s2,s1 => 3,s2 => 5}
cancelation: Ignore cancelation in stage s2.
HB: #{cancel_requested => true,current_stage => s3,s1 => 3,s2 => 5,s3 => 1}
cancelation: Cleanup and cancelation in stage s3.
{#{started => true,
   request_id =>
       "cluster_1-activity_heartbeat_workflow-88914644-d406-4c9c-9e76-3521d3720539",
   workflow_execution =>
       #{workflow_id =>
             "activity_heartbeat_workflow/d02fa362-9bea-4508-896c-b1ae9d86e56a",
         run_id => <<"019a1fc0-6924-726a-a456-f9999fc9acfb">>}},
 {completed,#{result => ["stage s3 cancelation"],
              workflow_task_completed_event_id => 16,
              new_execution_run_id => <<>>}}}
```

Sample source:
[src/activity_heartbeat](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/activity_heartbeat)

<!-- tabs-close -->

REMAINDER: Activity can only be canceled if it has a `heartbeat_timeout` option set, otherwise
workflow execution will fail.
