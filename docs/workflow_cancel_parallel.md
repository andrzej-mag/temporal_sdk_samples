Workflow execution cancellation and cleanup handling with parallel execution.

Workflow in this sample executes ten activities in parallel, each taking some time to complete.
It is expected that the workflow may be canceled. Upon receiving a cancel request, the workflow
implementation must:

1. Cancel any open activities.
2. Run an additional cleanup activity before the workflow completes.

The workflow cancel request event is handled by a `cancelation_handler` parallel execution.
To retrieve the list of open activities requiring cancellation, the
`temporal_sdk_workflow:select_index/1` SDK command is used.
The sample `run/1` function expects a positive integer argument, representing the duration
(in milliseconds) to wait before the cancel workflow command is executed.

Example run:
<!-- tabs-open -->

### Elixir

```elixir
iex(1)> WorkflowCancelParallel.run(1)
Running cleanup activity. Canceled activities count: 10.
{:canceled,
 %{details: [["Cleanup successful."]], workflow_task_completed_event_id: 59}}
iex(2)> WorkflowCancelParallel.run(5_000)
Running cleanup activity. Canceled activities count: 6.
{:canceled,
 %{details: [["Cleanup successful."]], workflow_task_completed_event_id: 68}}
iex(3)> WorkflowCancelParallel.run(10_000)
Running cleanup activity. Canceled activities count: 1.
{:canceled,
 %{details: [["Cleanup successful."]], workflow_task_completed_event_id: 72}}
iex(4)> WorkflowCancelParallel.run(11_000)
{:completed,
 %{
   result: [["Workflow cancel request event not received."]],
   workflow_task_completed_event_id: 64,
   new_execution_run_id: ""
 }}
```

Sample source:
[lib/workflow_cancel_parallel](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/workflow_cancel_parallel)

### Erlang

```erlang
1> workflow_cancel_parallel:run(1).
Running cleanup activity. Canceled activities count: 10.
{canceled,#{details => [[<<"Cleanup successful.">>]],
            workflow_task_completed_event_id => 57}}
2> workflow_cancel_parallel:run(5_000).
Running cleanup activity. Canceled activities count: 6.
{canceled,#{details => [[<<"Cleanup successful.">>]],
            workflow_task_completed_event_id => 71}}
3> workflow_cancel_parallel:run(10_000).
Running cleanup activity. Canceled activities count: 1.
{canceled,#{details => [[<<"Cleanup successful.">>]],
            workflow_task_completed_event_id => 75}}
4> workflow_cancel_parallel:run(11_000).
{completed,#{result =>
                 [[<<"Workflow cancel request event not received.">>]],
             workflow_task_completed_event_id => 64,
             new_execution_run_id => <<>>}}
```

Sample source:
[src/workflow_cancel_parallel](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/workflow_cancel_parallel)

<!-- tabs-close -->
