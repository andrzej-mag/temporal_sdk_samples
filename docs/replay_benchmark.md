Synthetic benchmark of the selected workflow commands during workflow execution and
[replay](https://docs.temporal.io/encyclopedia/event-history/event-history-typescript#How-History-Replay-Provides-Durable-Execution).

Benchmark is implemented as a `replay_benchmark_workflow` / `ReplayBenchmark.Workflow` workflow,
which starts and awaits 1000
[workflow commands](https://docs.temporal.io/workflow-execution#command) of a given kind as a single
[workflow task](https://docs.temporal.io/tasks#workflow-task).
After given workflow task is completed in the first workflow execution, an error is thrown using
`erlang:throw/1` to force a [workflow Replay](https://docs.temporal.io/workflow-execution#replay).
Command and [event](https://docs.temporal.io/workflow-execution/event#event) (approximate) processing
rates are reported for both workflow execution and workflow replay.

Following workflow awaitables can be benchmarked:

- `activity` - same as `regular_execution_activity`,
- `regular_execution_activity` - regular execution activity,
- `eager_execution_activity` - eager execution activity,
- `activity_await_cmd` - regular execution activity awaitable awaited in the `cmd` state,
- `marker` - marker awaited in the `value` state,
- `recorded_marker` - marker awaited in the `close` state.

Example benchmark results (error messages are omitted):

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> :replay_benchmark.start(:regular_execution_activity)
EXECUTION: 900 commands per second, 2707 events per second.

13:58:02.379 [error] Process #PID<0.851.0> raised an exception
** (ErlangError) Erlang error: {:nocatch, ~c"Force workflow replay."}
    (temporal_sdk_samples 0.1.13) src/replay_benchmark/replay_benchmark_workflow.erl:28:
# ...
REPLAY: 36756 commands per second, 110635 events per second.
:ok

iex(2)> :replay_benchmark.start(:eager_execution_activity)
EXECUTION: 1374 commands per second, 4131 events per second.
# ...
REPLAY: 32508 commands per second, 97753 events per second.
:ok

iex(3)> :replay_benchmark.start(:activity_await_cmd)
EXECUTION: 61232 commands per second, 0 events per second.
REPLAY: 79429 commands per second, 0 events per second.

iex(4)> :replay_benchmark.start(:marker)
EXECUTION: 47136 commands per second, 141 events per second.
REPLAY: 55032 commands per second, 55252 events per second.

iex(5)> :replay_benchmark.start(:recorded_marker)
EXECUTION: 11801 commands per second, 11872 events per second.
REPLAY: 84173 commands per second, 84762 events per second.
```

Sample source:
[src/replay_benchmark](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/replay_benchmark)

### Erlang

```erlang
1> replay_benchmark:start(regular_execution_activity).
EXECUTION: 904 commands per second, 2720 events per second.

=ERROR REPORT==== 13-Feb-2026::13:42:40.070342 ===
Error in process <0.900.0> with exit value:
{{nocatch,"Force workflow replay."},
% ...
REPLAY: 34432 commands per second, 103640 events per second.
ok

2> replay_benchmark:start(eager_execution_activity).
EXECUTION: 1410 commands per second, 4237 events per second.
% ...
REPLAY: 30803 commands per second, 92624 events per second.
ok

3> replay_benchmark:start(activity_await_cmd).
EXECUTION: 62177 commands per second, 0 events per second.
REPLAY: 49406 commands per second, 0 events per second.

4> replay_benchmark:start(marker).
EXECUTION: 35808 commands per second, 107 events per second.
REPLAY: 75745 commands per second, 76048 events per second.

5> replay_benchmark:start(recorded_marker).
EXECUTION: 8315 commands per second, 8365 events per second.
REPLAY: 46651 commands per second, 46978 events per second.
```

Sample source:
[src/replay_benchmark](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/replay_benchmark)

<!-- tabs-close -->
