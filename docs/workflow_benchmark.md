Synthetic workflow execution benchmark.

Workflow execution is benchmarked by starting and awaiting 100 `workflow_benchmark_workflow` workflow
executions in parallel. The entire benchmark is repeated 5 times.
Workflow execution rates per second are reported for each benchmark run and averaged across all runs.

Example benchmark run:

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> :workflow_benchmark.start()
Run 1 of 5. Workflows per second: 253.
Run 2 of 5. Workflows per second: 287.
Run 3 of 5. Workflows per second: 283.
Run 4 of 5. Workflows per second: 288.
Run 5 of 5. Workflows per second: 42.
Average workflows per second: 231.
:ok
```

Sample source:
[src/workflow_benchmark](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/workflow_benchmark)

### Erlang

```erlang
1> workflow_benchmark:start().
Run 1 of 5. Workflows per second: 42.
Run 2 of 5. Workflows per second: 244.
Run 3 of 5. Workflows per second: 295.
Run 4 of 5. Workflows per second: 295.
Run 5 of 5. Workflows per second: 285.
Average workflows per second: 232.
ok
```

Sample source:
[src/workflow_benchmark](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/workflow_benchmark)

<!-- tabs-close -->
