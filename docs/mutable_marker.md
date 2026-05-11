Mutable marker sample.

This sample workflow implementation performs the following steps:

1. Start and await the `first_activity` activity.
2. Record the mutable OS env marker from the `mutable_marker` OS environment variable.
3. Start the `second_activity` long-running activity, whose input depends on the mutable recorded
   marker value from step 2.

To demonstrate the mutable marker functionality we simulate three worker node restarts using a timer
and `temporal_sdk_workflow:terminate_executor/0`.
After the workflow executor is forcefully terminated, workflow task timeouts which can be ignored
in this context. This triggers workflow execution retry replaying existing workflow history events.
During workflow replay `first_activity` and `mutable_marker` results are fetched from the history.
If the count of mutable marker mutations is less than the mutation limit, the SDK executes the function
that evaluates the `mutable_marker` value during replay.
If the current marker value differs from the value recorded in the workflow events history, the SDK
resets the workflow execution to the task-finish event that immediately precedes the mutable marker.
The Temporal server then starts a new, reset workflow execution.
After each mutation of the marker and workflow reset, the `second_activity` is started with new,
mutated input.

During sample runs, the Temporal server returns "workflow execution already completed" errors
when handling `"RespondActivityTaskCompleted"` gRPC requests for `second_activity`.
These errors occur because SDK activity executors for `second_activity` are unaware of parent workflow
resets and still attempt to dispatch `RespondActivityTaskCompleted` to workflow executions that have
already been closed.

Example run (error messages are omitted):

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> MutableMarker.run()
:ok
Mutable Marker - mutations count: 0, marker value: 49.
Mutable Marker - mutations count: 1, marker value: 51.

14:29:59.482 [error] [reason: %{grpc_response_headers:
...
Mutable Marker - mutations count: 2, marker value: 53.
Mutable Marker - mutations count: 3, marker value: 55.
```

Sample source:
[lib/mutable_marker](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/mutable_marker)

### Erlang

```erlang
1> mutable_marker:run().
ok
Mutable Marker - mutations count: 0, marker value: 49.
Mutable Marker - mutations count: 1, marker value: 51.
=ERROR REPORT==== 20-Mar-2026::13:54:11.521082 ===
    reason: #{grpc_response_headers =>
...
Mutable Marker - mutations count: 2, marker value: 53.
Mutable Marker - mutations count: 3, marker value: 55.
```

Sample source:
[src/mutable_marker](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/mutable_marker)

<!-- tabs-close -->
