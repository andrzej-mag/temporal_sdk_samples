Rate limiter dynamic configuration with dynamic activity task worker sample.

SDK provides the following rate limiters:

- OS rate limiter,
- concurrency and fixed window rate limiters at the SDK node, SDK cluster and task worker levels,
- task worker task poller leaky bucket rate limiter.

Refer to the `m:temporal_sdk_limiter` documentation for more details.
This sample is narrowed to the concurrency rate limiter at the task worker level.
Other rate limiters can be managed in a similar manner to the approach presented here.

Sample implements a Temporal workflow definition that schedules 10 regular activities in parallel.
Each activity takes 1 second to execute.
Activities are scheduled on a dedicated activity task queue.
A dynamic activity task worker is started to process tasks from that queue.
Activity task worker concurrency rate limiter limits are dynamically updated in the example commands below.
Initial activity task worker concurrency rate limiter limits are set to unlimited.

Sample utilizes simple syntactic sugar wrappers built upon task worker module functions, refer to the
sample source code for implementation details:

- Elixir:
  [lib/rate_limiter](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/rate_limiter)
- Erlang:
  [src/rate_limiter](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/rate_limiter)

Start activity task worker `"limited_worker"` polling activity tasks from `"limited_tq"` activity task queue:

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> RateLimiter.start_worker()
{:ok,
 %{
   task_queue: "limited_tq",
   worker_id: "limited_worker",
   task_poller_pool_size: 1,
   limits: %{node: %{}, os: %{}, worker: %{}, cluster: %{}},
   task_settings: %{
     data: :undefined,
     last_heartbeat: [:undefined],
     heartbeat_timeout_ratio: 0.8,
     schedule_to_close_timeout_ratio: 0.8,
     start_to_close_timeout_ratio: 0.8
   },
   namespace: ~c"default",
   telemetry_poll_interval: 10000,
   limiter_time_windows: %{activity_regular: 60000},
   worker_version: %{},
   task_poller_limiter: %{limit: :infinity, time_window: :undefined},
   limiter_check_frequency: 500,
   temporal_name_to_erlang: &:temporal_sdk_api.temporal_name_to_erlang/2,
   allowed_erlang_modules: :all,
   allowed_temporal_names: :all
 }}
```

### Erlang

```erlang
1> rate_limiter:start_worker().
{ok,#{namespace => "default",worker_id => "limited_worker",
      task_queue => "limited_tq",task_poller_pool_size => 1,
      limits =>
          #{node => #{},os => #{},worker => #{},cluster => #{}},
      telemetry_poll_interval => 10000,
      limiter_time_windows => #{activity_regular => 60000},
      worker_version => #{},
      task_settings =>
          #{data => undefined,
            last_heartbeat => [undefined],
            heartbeat_timeout_ratio => 0.8,
            schedule_to_close_timeout_ratio => 0.8,
            start_to_close_timeout_ratio => 0.8},
      task_poller_limiter =>
          #{limit => infinity,time_window => undefined},
      limiter_check_frequency => 500,
      temporal_name_to_erlang =>
          fun temporal_sdk_api:temporal_name_to_erlang/2,
      allowed_erlang_modules => all,
      allowed_temporal_names => all}}
```
<!-- tabs-close -->

Start workflow execution without rate limiting and await workflow execution completion:

<!-- tabs-open -->
### Elixir

```elixir
iex(2)> RateLimiter.start()
Executing activity number 4
Executing activity number 8
Executing activity number 2
Executing activity number 3
Executing activity number 7
Executing activity number 6
Executing activity number 9
Executing activity number 1
Executing activity number 10
Executing activity number 5
Workflow completed in 1090 msec.
```

### Erlang

```erlang
2> rate_limiter:start().
Executing activity number 8
Executing activity number 4
Executing activity number 2
Executing activity number 10
Executing activity number 3
Executing activity number 1
Executing activity number 6
Executing activity number 5
Executing activity number 7
Executing activity number 9
Workflow completed in 1050 msec.
```
<!-- tabs-close -->

Workflow executes 10 activities in parallel without rate limiting.
A single activity takes 1000 milliseconds to execute.
Because all activities are executed without concurrency limits, the total workflow execution time is
1x1000 milliseconds plus overhead.
Activities execution order is determined by the (random) polling order of activity tasks.

Set the activity task worker regular activities concurrency limits to 1 for the `"limited_worker"`:

<!-- tabs-open -->
### Elixir

```elixir
iex(3)> RateLimiter.set_worker_concurrency_limit(1)
:ok
iex(4)> RateLimiter.get_worker_concurrency_limit()
{:ok, 1}
```

### Erlang

```erlang
3> rate_limiter:set_worker_concurrency_limit(1).
ok
4> rate_limiter:get_worker_concurrency_limit().
{ok,1}
```
<!-- tabs-close -->

Start a new workflow execution, this time with activity concurrency restricted to one:

<!-- tabs-open -->
### Elixir

```elixir
iex(5)> RateLimiter.start()
Executing activity number 10
Executing activity number 6
Executing activity number 4
Executing activity number 2
Executing activity number 5
Executing activity number 8
Executing activity number 7
Executing activity number 9
Executing activity number 3
Executing activity number 1
Workflow completed in 11241 msec.
```

### Erlang

```erlang
5> rate_limiter:start().
Executing activity number 1
Executing activity number 5
Executing activity number 2
Executing activity number 4
Executing activity number 7
Executing activity number 8
Executing activity number 3
Executing activity number 9
Executing activity number 10
Executing activity number 6
Workflow completed in 11055 msec.
```
<!-- tabs-close -->

Activity task worker `"limited_worker"` is limited to executing one activity task concurrently.
Workflow execution time is 10x1000 milliseconds plus overhead.

Experiment with different activity task worker rate limiter concurrency limits:

<!-- tabs-open -->
### Elixir

```elixir
iex(6)> RateLimiter.set_worker_concurrency_limit(5)
:ok
iex(7)> RateLimiter.start()
...
```

### Erlang

```erlang
6> rate_limiter:set_worker_concurrency_limit(5).
ok
7> rate_limiter:start().
...
```
<!-- tabs-close -->

Optionally terminate dynamic activity task worker:

<!-- tabs-open -->
### Elixir

```elixir
iex(8)> RateLimiter.terminate_worker()
:ok
```

### Erlang

```erlang
8> rate_limiter:terminate_worker().
ok
```
<!-- tabs-close -->

### NOTES

The `"limited_worker"` activity task worker `task_poller_pool_size` configuration option is set
to 1 because the task poller pool size must be less than or equal to the concurrency limits.

In most real-world use cases, the `"limited_worker"` activity task worker runs across an Erlang cluster
of SDK worker nodes. This requires setting rate-limiter concurrency limits on the multiple worker nodes,
which is done using the `temporal_sdk_worker:set_limiter_config/5` function.
To mitigate brain-split scenarios in Erlang clusters, you can periodically call `set_limiter_config/5`
within a [Temporal Schedule](https://docs.temporal.io/schedule).
