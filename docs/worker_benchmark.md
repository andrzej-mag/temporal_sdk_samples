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
Run 1 of 5. Workers per second: 3061.
Run 2 of 5. Workers per second: 2028.
Run 3 of 5. Workers per second: 2029.
Run 4 of 5. Workers per second: 2218.
Run 5 of 5. Workers per second: 1159.
Average workers per second: 2099.
:ok
```

Sample source:
[src/worker_benchmark](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/worker_benchmark)

### Erlang

```erlang
1> worker_benchmark:start().
Run 1 of 5. Workers per second: 3132.
Run 2 of 5. Workers per second: 2323.
Run 3 of 5. Workers per second: 2276.
Run 4 of 5. Workers per second: 2515.
Run 5 of 5. Workers per second: 1228.
Average workers per second: 2295.
ok
```

Sample source:
[src/worker_benchmark](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/worker_benchmark)

<!-- tabs-close -->

When running this benchmark, it is recommended to use the Temporal CLI dev server and to restart the
Temporal server after each benchmark run to avoid exceeding the Temporal server's service rate limits.

Single benchmark run opens 500 `PollActivityTaskQueueRequest` long-poll gRPC requests running in
parallel, which may require increasing the OS File Descriptor limits.
