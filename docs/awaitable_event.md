Demonstrates how to use awaitable events with the `ActivityTaskStarted` event.

Successfully completed regular activity awaitable transitions through the following states:

- `cmd` – the "command" state, set when the activity is started via the `start_activity()` command,
- `scheduled` – state after the Temporal server schedules activity and records the `ActivityTaskScheduled`
  event in the events history,
- `started` – state after SDK’s activity task worker successfully polls activity task and the
  `ActivityTaskStarted` event is recorded,
- `completed` – state after activity executor successfully completes activity execution and the
  `ActivityTaskCompleted` event is recorded.

See the `m:temporal_sdk_workflow` module documentation for more information on awaitables.

Workflow used in this sample starts an `echo_activity` activity and sets its awaitable event to `start`.
Awaiting this awaitable will block until the activity transitions to the `started` state, however
transition to the `completed` state is not required.

Activity is started on the `"awaitable_event"` task queue.
Activity awaitable with event set to `start` is awaited with a 1-second timeout. If the activity
worker polling `"awaitable_event"` task queue is unavailable and activity execution does not start
within the timeout, a `WARN` message is logged.
Finally, the activity awaitable event is set to the closed state, and awaiting an
awaitable in a closed state follows as in the most common use cases.

Such a pattern can be useful, for example, when workflow logic requires prior knowledge of issues
related to a given activity worker, without failing the activity through conventional activity timeouts.

Example run:

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> AwaitableEvent.run(0)
Start activity worker
INFO: Activity started within 1000 msec timeout.
<<"Activity completed.">>
:ok
#
# Restart session here to terminate running activity worker
#
iex(1)> AwaitableEvent.run(2000)
WARN: Activity NOT started within 1000 msec timeout.
Start activity worker
<<"Activity completed.">>
:ok
iex(2)> AwaitableEvent.run(2000)
Activity worker already started
INFO: Activity started within 1000 msec timeout.
<<"Activity completed.">>
:ok
```

Sample source:
[lib/awaitable_event](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/awaitable_event)

### Erlang

```erlang
1> awaitable_event:run(0).
Start activity worker.
INFO: Activity started within 1000 msec timeout.
<<"Activity completed.">>
ok
%
% Restart session here to terminate running activity worker
%
1> awaitable_event:run(2000).
WARN: Activity NOT started within 1000 msec timeout.
Start activity worker.
<<"Activity completed.">>
ok
2> awaitable_event:run(2000).
Activity worker already started.
INFO: Activity started within 1000 msec timeout.
<<"Activity completed.">>
ok
```

Sample source:
[src/awaitable_event](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/awaitable_event)

<!-- tabs-close -->
