Workflow eviction implemented with `handle_eviction()` callback, accompanied by a dedicated telemetry
event handler to monitor eviction related events.

Workflow implementation in this sample performs the following steps:

1. Executes three activities sequentially.
2. Waits for a signal with a timeout. Since awaiting a signal may take a significant amount of time,
   the workflow is evicted to release resources.
3. After the signal wait concludes, the next three activities are executed sequentially.
   Workflow eviction is postponed until the activities are completed and signal is acknowledged.
4. Acknowledges the signal awaitable.
5. Executes the final set of three sequential activities; workflow eviction is allowed again.

All workflow activities take synthetic binary data as input, with the size specified by the first
argument of the `run()` command.

Workflow eviction is managed by the `c:temporal_sdk_workflow:handle_eviction/2` callback function
implementation. Eviction behavior depends on the signal awaitable state, eviction strategy, and
optionally `history_size_bytes`.
Workflow is not evicted if the signal awaitable is in the `requested` state.

Available eviction strategies:

- `always`: Workflow is evicted regardless of the events history size.
- `custom`: If events history size exceeds 500,000 bytes, workflow is evicted on each workflow task
  completion request.
- `never`: Workflow is not evicted.

The `handle_eviction/2` callback function is invoked after the gRPC `RespondWorkflowTaskCompletedRequest`
call, which by default requests the Temporal server to dispatch new workflow task on the sticky queue.
If the workflow execution is evicted after this call, it becomes impossible to notify the Temporal server
that next workflow task should be dispatched on the regular task queue. As a result, the server
dispatches a stale workflow task on the sticky queue. Such occurrences are reported via the task
poller's `sticky_miss` event.

When the `run()` function executes, an event handler is attached to the
`[temporal_sdk, workflow, executor, stop]` and `[temporal_sdk,poller,execute,stop]` telemetry events.

For `[temporal_sdk, workflow, executor, stop]` event workflow `closing_state` and `event_id` are
logged.
For `[temporal_sdk, poller, execute, stop]` event `task_execute_status` metadata is logged
for the `sticky_queue` pollers.

Example run:

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> WorkflowEviction.run(70_000, :custom)
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 57 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 63 -> completed
:ok
iex(2)> WorkflowEviction.run(100_000, :custom)
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 45 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 51 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 57 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 63 -> completed
:ok
iex(3)> WorkflowEviction.run(500_000, :custom)
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 9 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 15 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 45 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 51 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 57 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 63 -> completed
:ok
iex(4)> WorkflowEviction.run(1_000, :always)
[temporal_sdk,workflow,executor,stop]: 3 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 9 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 15 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 45 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 51 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 57 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 63 -> completed
:ok
iex(5)> WorkflowEviction.run(1_000, :never)
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 63 -> completed
:ok
```

Sample source:
[lib/workflow_eviction](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/workflow_eviction)

### Erlang

```erlang
1> workflow_eviction:run(70_000, custom).
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 57 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 63 -> completed
ok
2> workflow_eviction:run(100_000, custom).
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 45 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 51 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 57 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 63 -> completed
ok
3> workflow_eviction:run(500_000, custom).
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 9 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 15 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 45 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 51 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 57 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 63 -> completed
ok
4> workflow_eviction:run(1_000, always).
[temporal_sdk,workflow,executor,stop]: 3 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 9 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 15 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 45 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 51 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 57 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_miss
[temporal_sdk,workflow,executor,stop]: 63 -> completed
ok
5> workflow_eviction:run(1_000, never).
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 63 -> completed
ok
```

Sample source:
[src/workflow_eviction](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/workflow_eviction)

<!-- tabs-close -->

Note: This sample uses an aggressive workflow eviction strategy to illustrate the SDK's eviction
approach. For a detailed discussion of practical eviction performance considerations, see the
[SDK Architecture - Workflow Eviction](`e:temporal_sdk:architecture.md#workflow-eviction`) section.
