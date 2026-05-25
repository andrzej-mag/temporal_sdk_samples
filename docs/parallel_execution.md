Demonstrates the use of nested parallel executions running concurrently.

This workflow example shows how to leverage SDK parallel executions to improve code structure and add
execution concurrency when implementing business logic in workflows.

Example run:

<!-- tabs-open -->

### Elixir

```elixir
iex(1)> ParallelExecution.run({"hello", "world", "from", "temporal"})
{:completed,
 %{
   result: [["HELLO", "WORLD", "FROM", "TEMPORAL"]],
   workflow_task_completed_event_id: 34,
   new_execution_run_id: ""
 }}
```

Sample source:
[lib/parallel_execution](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/parallel_execution)

### Erlang

```erlang
1> parallel_execution:run({~"hello", ~"world", ~"from", ~"temporal"}).
{completed,#{result =>
                 [[<<"HELLO">>,<<"WORLD">>,<<"FROM">>,<<"TEMPORAL">>]],
             workflow_task_completed_event_id => 34,
             new_execution_run_id => <<>>}}
```

Sample source:
[src/parallel_execution](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/parallel_execution)

<!-- tabs-close -->
