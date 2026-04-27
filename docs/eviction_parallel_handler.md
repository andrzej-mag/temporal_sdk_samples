Workflow eviction implemented via parallel execution handler, accompanied by a dedicated telemetry
event handler to monitor eviction related events.

This sample is a variation of the "Workflow Eviction" sample.
Workflow eviction is managed here by a dedicated parallel execution handler, `eviction_handler/2`,
which processes consecutive Temporal events and invokes the `evict_workflow/0` SDK command to evict
workflow. If a Temporal history event includes a `history_size_bytes` field in a `WorkflowTaskStartedEvent`,
the eviction logic is applied according to the specified eviction strategy.
Eviction requests in this sample are known in advance of the gRPC `RespondWorkflowTaskCompletedRequest`
call, enabling SDK to avoid polling stale workflow tasks from the sticky queue.

Example run:

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> EvictionParallelHandler.run(70_000, :custom)
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
[temporal_sdk,workflow,executor,stop]: 63 -> completed
:ok
iex(2)> EvictionParallelHandler.run(100_000, :custom)
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 51 -> evicted
[temporal_sdk,workflow,executor,stop]: 57 -> evicted
[temporal_sdk,workflow,executor,stop]: 63 -> completed
:ok
iex(3)> EvictionParallelHandler.run(500_000, :custom)
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 9 -> evicted
[temporal_sdk,workflow,executor,stop]: 15 -> evicted
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 51 -> evicted
[temporal_sdk,workflow,executor,stop]: 57 -> evicted
[temporal_sdk,workflow,executor,stop]: 63 -> completed
:ok
iex(4)> EvictionParallelHandler.run(1_000, :always)
[temporal_sdk,workflow,executor,stop]: 3 -> evicted
[temporal_sdk,workflow,executor,stop]: 9 -> evicted
[temporal_sdk,workflow,executor,stop]: 15 -> evicted
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 51 -> evicted
[temporal_sdk,workflow,executor,stop]: 57 -> evicted
[temporal_sdk,workflow,executor,stop]: 63 -> completed
:ok
iex(5)> EvictionParallelHandler.run(1_000, :never)
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
[lib/eviction_parallel_handler](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/eviction_parallel_handler)

### Erlang

```erlang
1> eviction_parallel_handler:run(70_000, custom).
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
[temporal_sdk,workflow,executor,stop]: 63 -> completed
ok
2> eviction_parallel_handler:run(100_000, custom).
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 51 -> evicted
[temporal_sdk,workflow,executor,stop]: 57 -> evicted
[temporal_sdk,workflow,executor,stop]: 63 -> completed
ok
3> eviction_parallel_handler:run(500_000, custom).
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 9 -> evicted
[temporal_sdk,workflow,executor,stop]: 15 -> evicted
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 51 -> evicted
[temporal_sdk,workflow,executor,stop]: 57 -> evicted
[temporal_sdk,workflow,executor,stop]: 63 -> completed
ok
4> eviction_parallel_handler:run(1_000, always).
[temporal_sdk,workflow,executor,stop]: 3 -> evicted
[temporal_sdk,workflow,executor,stop]: 9 -> evicted
[temporal_sdk,workflow,executor,stop]: 15 -> evicted
[temporal_sdk,workflow,executor,stop]: 21 -> evicted
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,poller,execute,stop]: sticky_hit
[temporal_sdk,workflow,executor,stop]: 51 -> evicted
[temporal_sdk,workflow,executor,stop]: 57 -> evicted
[temporal_sdk,workflow,executor,stop]: 63 -> completed
ok
5> eviction_parallel_handler:run(1_000, never).
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
[src/eviction_parallel_handler](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/eviction_parallel_handler)

<!-- tabs-close -->
