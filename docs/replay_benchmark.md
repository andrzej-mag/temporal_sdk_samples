Synthetic benchmark of the selected workflow tasks during workflow execution and
[replay](https://docs.temporal.io/encyclopedia/event-history/event-history-typescript#How-History-Replay-Provides-Durable-Execution).

Benchmark is implemented as a `replay_benchmark_workflow` workflow.
`replay_benchmark_workflow` executes and awaits 1000 workflow tasks of a given kind.
After the workflow tasks are completed in the first workflow execution, an error is thrown using
`erlang:throw/1` to force a [workflow replay](https://docs.temporal.io/workflow-execution#replay).
Task execution rates are reported for both workflow execution and workflow replay.

Following tasks can be benchmarked:

- `activity` - same as `regular_execution_activity`,
- `regular_execution_activity` - regular execution activity,
- `eager_execution_activity` - eager execution activity,
- `marker` - marker value immediately returned without recording to the Temporal server,
- `recorded_marker` - marker recorded to the Temporal server and awaited.

Example benchmark results (error messages are omitted):

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> :replay_benchmark.start(:regular_execution_activity)
EXECUTION. Tasks per second: 987.

13:58:02.379 [error] Process #PID<0.851.0> raised an exception
** (ErlangError) Erlang error: {:nocatch, ~c"Force workflow replay."}
    (temporal_sdk_samples 0.1.13) src/replay_benchmark/replay_benchmark_workflow.erl:28:
# ...
REPLAY. Tasks per second: 31659.
:ok

iex(2)> :replay_benchmark.start(:eager_execution_activity)
EXECUTION. Tasks per second: 1471.
# ...
REPLAY. Tasks per second: 37831.
:ok

iex(4)> :replay_benchmark.start(:marker)
EXECUTION. Tasks per second: 25465.
REPLAY. Tasks per second: 72856.

iex(5)> :replay_benchmark.start(:recorded_marker)
EXECUTION. Tasks per second: 10712.
REPLAY. Tasks per second: 61774.
```

Sample source:
[src/replay_benchmark](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/replay_benchmark)

### Erlang

```erlang
1> replay_benchmark:start(regular_execution_activity).
EXECUTION. Tasks per second: 995.

=ERROR REPORT==== 13-Feb-2026::13:42:40.070342 ===
Error in process <0.900.0> with exit value:
{{nocatch,"Force workflow replay."},
% ...
REPLAY. Tasks per second: 35696.
ok

2> replay_benchmark:start(eager_execution_activity).
EXECUTION. Tasks per second: 1361.
% ...
REPLAY. Tasks per second: 34750.
ok

3> replay_benchmark:start(marker).
EXECUTION. Tasks per second: 25544.
REPLAY. Tasks per second: 68438.

4> replay_benchmark:start(recorded_marker).
EXECUTION. Tasks per second: 9796.
REPLAY. Tasks per second: 50882.
```

Sample source:
[src/replay_benchmark](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/replay_benchmark)

<!-- tabs-close -->
