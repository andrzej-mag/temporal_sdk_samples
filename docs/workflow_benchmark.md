Synthetic regular and [eager](https://docs.temporal.io/develop/worker-performance#eager-workflow-start)
workflow execution benchmark.

Workflow execution is benchmarked by starting and awaiting 100 `workflow_benchmark_workflow` workflow
executions in parallel.
Workflow executions are scheduled on a dedicated task queue that is polled by a dynamic workflow task
worker with a configurable `task_poller_pool_size` setting.
Benchmark runs are repeated 5 times.
Workflow execution rates per second are reported for each benchmark run and averaged across all runs.

Function starting benchmark requires two arguments:

- request eager workflow execution as a boolean,
- workflow task worker `task_poller_pool_size` configuration option as a positive integer.

Example benchmark results:

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> :workflow_benchmark.start(:true, 1)
Run 1 of 5. Workflows per second: 360.
Run 2 of 5. Workflows per second: 344.
Run 3 of 5. Workflows per second: 405.
Run 4 of 5. Workflows per second: 374.
Run 5 of 5. Workflows per second: 387.
Average workflows per second: 374.
:ok
iex(2)> :workflow_benchmark.start(:false, 1)
Run 1 of 5. Workflows per second: 41.
Run 2 of 5. Workflows per second: 41.
Run 3 of 5. Workflows per second: 41.
Run 4 of 5. Workflows per second: 41.
Run 5 of 5. Workflows per second: 42.
Average workflows per second: 41.
:ok
iex(3)> :workflow_benchmark.start(:false, 10)
Run 1 of 5. Workflows per second: 287.
Run 2 of 5. Workflows per second: 285.
Run 3 of 5. Workflows per second: 288.
Run 4 of 5. Workflows per second: 293.
Run 5 of 5. Workflows per second: 286.
Average workflows per second: 288.
:ok
```

Sample source:
[src/workflow_benchmark](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/workflow_benchmark)

### Erlang

```erlang
1> workflow_benchmark:start(true, 1).
Run 1 of 5. Workflows per second: 381.
Run 2 of 5. Workflows per second: 374.
Run 3 of 5. Workflows per second: 414.
Run 4 of 5. Workflows per second: 401.
Run 5 of 5. Workflows per second: 342.
Average workflows per second: 382.
ok
2> workflow_benchmark:start(false, 1).
Run 1 of 5. Workflows per second: 10.
Run 2 of 5. Workflows per second: 41.
Run 3 of 5. Workflows per second: 41.
Run 4 of 5. Workflows per second: 41.
Run 5 of 5. Workflows per second: 41.
Average workflows per second: 35.
ok
3> workflow_benchmark:start(false, 10).
Run 1 of 5. Workflows per second: 268.
Run 2 of 5. Workflows per second: 284.
Run 3 of 5. Workflows per second: 292.
Run 4 of 5. Workflows per second: 278.
Run 5 of 5. Workflows per second: 288.
Average workflows per second: 282.
```

Sample source:
[src/workflow_benchmark](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/workflow_benchmark)

<!-- tabs-close -->

Benchmark is CPU-intensive. The results above were obtained on a 12-core CPU machine with the Temporal
CLI dev server running locally.

```shell
$> lscpu | grep -E '^Thread|^Core|^Socket|^CPU\('
CPU(s):                                  12
Thread(s) per core:                      2
Core(s) per socket:                      6
Socket(s):                               1
```
