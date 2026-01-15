Rate limiter dynamic configuration with dynamic activity task worker.

Sample defines a workflow that schedules 10 regular activities in parallel.
Each activity takes 1 second to execute.
Activities are scheduled on a dedicated activity task queue.
A dynamic activity task worker is started to process tasks from that queue.
Activity task worker rate limiter limits are dynamically updated in the example run below.
Initial activity task worker rate limiter limits are set to unlimited.

Sample utilizes simple syntactic sugar wrappers built upon task worker module functions, refer to the
sample source code for implementation details:

- Elixir:
  [lib/rate_limiter](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/rate_limiter)
- Erlang:
  [src/rate_limiter](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/rate_limiter)

Start activity task worker `"limited_worker"` running on `"limited_tq"` task queue:
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

Start workflow execution without rate limiting:

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

Workflow executes 10 activities concurrently with no rate limiting restrictions.
As a single activity executes in 1000 milliseconds and all activities are executed concurrently without
restrictions, workflow execution duration is 1x1000 milliseconds plus overhead.
Activities execution order is determined by the polling order of activity tasks.

Set the activity task worker regular activities concurrency limits to 1 for the "limited_worker":

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

Start workflow execution again, this time with restricted concurrency limits:

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

Activity task worker `"limited_worker"` is limited to executing only one activity task concurrently.
Workflow execution duration is 10x1000 milliseconds plus overhead.

Optionally terminate dynamic activity task worker:

<!-- tabs-open -->
### Elixir

```elixir
iex(6)> RateLimiter.terminate_worker()
:ok
```

### Erlang

```erlang
6> rate_limiter:terminate_worker().
ok
```
<!-- tabs-close -->

NOTE: The activity task worker `task_poller_pool_size` configuration option is set to 1 because we
limit task concurrency to small values.
