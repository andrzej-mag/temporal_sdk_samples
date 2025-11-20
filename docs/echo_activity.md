"echo" activity used across samples.

Activity can be started with a following input variants:

* `[Echo]` - where `Echo` is any Erlang term that can be converted with current payload codec.
  `Echo` value is returned as activity result,
* `[Echo, SleepTime]` - activity will run `timer:sleep(SleepTime)` command pretendig of doing some
  work,
* `[Echo, SleepTime, FailedAttempts]` - activity execution will fail with
  `throw("Test echo_activity failure")` for `FailedAttempts` count.

If `byte_size(Echo) > 10_000` or `length(Echo) > 3_300` activity returns `~"large_payload"`
as a result.

Example:

<!-- tabs-open -->

### Elixir

```elixir
start_activity(:echo_activity, ["echo", 10_000, 3])
```

### Erlang

```erlang
start_activity(echo_activity, ["echo", 10_000, 3])
```

<!-- tabs-close -->
