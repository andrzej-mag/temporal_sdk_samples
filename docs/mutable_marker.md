Mutable marker sample.

This sample workflow implementation performs the following steps:

1. Start and await the "first_activity" activity.
2. Record the mutable env marker using the "mutable_marker" environment variable.
3. Start the "second_activity" long-running activity, whose input depends on the recorded marker value
   from step 2.

Additionally, the workflow implementation mocks mutations to the `mutable_marker` environment
variable and simulates (three) worker node restarts using a timer. Each restart mutates the
`mutable_marker` value, triggering workflow execution resets and re-scheduling of `second_activity`
with updated input.

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
