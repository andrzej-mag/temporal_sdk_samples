Workflow execution cancellation and usage of `await_open_before_close/1` sample.

Workflow implementation in this sample starts a single asynchronous, long-running activity.

The workflow handles the `{cancel_request}` workflow cancellation event based on the cancellation reasons:

- `cancel_all`: Cancels the long-running activity (if it is in the open state) and then cancels the workflow.
- `cancel_await`: Waits for any open tasks (long-running activity) to complete and then cancels the workflow.
- `cancel_abandon`: Cancels the workflow and abandons any open tasks by executing `await_open_before_close(false)` workflow SDK command.
- Any other cancellation reason: Waits for any open tasks to complete and fails workflow execution.

Example run:

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> WorkflowCancel.run(:cancel_all)
{:canceled, %{details: [["cancel_all"]], workflow_task_completed_event_id: 15}}
iex(2)> WorkflowCancel.run(:cancel_await)
{:canceled,
 %{details: [["cancel_await"]], workflow_task_completed_event_id: 14}}
iex(3)> WorkflowCancel.run(:cancel_abandon)
{:canceled,
 %{details: [["cancel_abandon"]], workflow_task_completed_event_id: 9}}
13:25:28.816 [error] [data: :undefined, reason: %{grpc_response_headers: [{"content-type", "application/grpc+proto"}, {"grpc-status", "5"}, {"grpc-message", "workflow execution already completed"}, telemetry_event: [:temporal_sdk, :activity, :task, :exception],
...
iex(4)> WorkflowCancel.run(:invalid_reason)
{:failed,
 %{
   failure: %{
     message: "<<\"Unrecognized cancel_workflow reason.\">>",
     source: "",
     stack_trace: "<<\"invalid_reason\">>"
   },
   retry_state: :RETRY_STATE_RETRY_POLICY_NOT_SET,
   workflow_task_completed_event_id: 14,
   new_execution_run_id: ""
 }}
```

Sample source:
[lib/workflow_cancel](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/workflow_cancel)

### Erlang

```erlang
1> workflow_cancel:run(cancel_all).
{canceled,#{details => [[<<"cancel_all">>]],
            workflow_task_completed_event_id => 15}}
2> workflow_cancel:run(cancel_await).
{canceled,#{details => [[<<"cancel_await">>]],
            workflow_task_completed_event_id => 14}}
3> workflow_cancel:run(cancel_abandon).
{canceled,#{details => [[<<"cancel_abandon">>]],
            workflow_task_completed_event_id => 9}}
=ERROR REPORT==== 10-Mar-2026::11:18:33.798906 ===
    data: undefined
    reason: #{grpc_response_headers =>
                  [{<<"content-type">>,<<"application/grpc+proto">>},
                   {<<"grpc-status">>,<<"5">>},
                   {<<"grpc-message">>,
                    <<"workflow execution already completed">>},
...
    telemetry_event: [temporal_sdk,activity,task,exception]
...
4> workflow_cancel:run(invalid_reason).
{failed,#{failure =>
              #{message => <<"Unrecognized cancel_workflow reason.">>,
                source => <<>>,stack_trace => <<"<<\"invalid_reason\">>">>},
          workflow_task_completed_event_id => 14,
          new_execution_run_id => <<>>,
          retry_state => 'RETRY_STATE_RETRY_POLICY_NOT_SET'}}
```

Sample source:
[src/workflow_cancel](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/workflow_cancel)

<!-- tabs-close -->

The error in the `cancel_abandon` scenario occurs when the activity executor sends a
`RespondActivityTaskCompletedRequest` gRPC call after the parent workflow
execution has already been closed-canceled.
