Synthetic dynamic activity task worker benchmark.

Dynamic activity task worker operations are benchmarked by starting and terminating 100 activity task
workers in parallel. The entire operation is repeated 5 times with a 2-second interval between each run.
Conservative benchmark limits are chosen to avoid exceeding the default Temporal server configuration
service rate limits.
Benchmark reports the rate of worker start-terminate operations per second.

Example benchmark run:

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> :worker_benchmark.start()
Run 1 of 5.
Run 2 of 5.
Run 3 of 5.
Run 4 of 5.
Run 5 of 5.
Workers per second: 1825.
:ok
```

### Erlang

```erlang
1> worker_benchmark:start().
Run 1 of 5.
Run 2 of 5.
Run 3 of 5.
Run 4 of 5.
Run 5 of 5.
Workers per second: 1595.
ok
```
<!-- tabs-close -->

When running this benchmark, it is recommended to use the Temporal CLI dev server and to restart the
Temporal server after each benchmark run to avoid exceeding the Temporal server's service rate limits.

Single benchmark run opens 500 `PollActivityTaskQueueRequest` long-poll gRPC requests running in
parallel, which may require increasing the OS File Descriptor limits.
