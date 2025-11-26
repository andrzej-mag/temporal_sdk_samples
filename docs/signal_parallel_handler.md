Example signal parallel handler.

Example workflow execution performs following tasks:

* count `"ping"` signals,
* complete workflow on `"kill"` signal,
* report current `"ping"` signals count on `"report"` signal,
* continue as new workflow execution on `suggest_continue_as_new` event,
* fail workflow on `"ping"` signals count exceeding 10_000.

To prevent Temporal server overload, `"ping"` signals are dispatched at 100 millisecond intervals.

Run this example with:
<!-- tabs-open -->

### Elixir

```elixir
SignalParallelHandler.start()
```

Sample source:
[lib/signal_parallel_handler](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/signal_parallel_handler)

### Erlang

```erlang
signal_parallel_handler:start().
```

Sample source:
[src/signal_parallel_handler](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/signal_parallel_handler)

<!-- tabs-close -->
