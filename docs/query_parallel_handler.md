Example query parallel handler.

Workflow defined in this example runs tasks in a multiple distinctive workflow execution stages:
init, stage_1, stage_2, wait_async, cleanup and finalize.
Workflow execution is queried every second with `<<"get_progress">>` query.
When workflow execution is in open state, progress query parallel handler responds with
workflow state `"open"` and current workflow execution stage.
When workflow execution is closed, conventional query handle callback function responds with
workflow state `"closed"` and last workflow history event type.
Query responses are echoed to the terminal.

Example run:

<!-- tabs-open -->

### Elixir

```elixir
iex(1)> QueryParallelHandler.start()
progress after 0 sec: ["open", "init"]
progress after 1 sec: ["open", "init"]
progress after 2 sec: ["open", "stage_1"]
progress after 3 sec: ["open", "stage_1"]
progress after 4 sec: ["open", "stage_2"]
progress after 5 sec: ["open", "stage_2"]
progress after 6 sec: ["open", "wait_async"]
progress after 7 sec: ["open", "wait_async"]
progress after 8 sec: ["open", "cleanup"]
progress after 9 sec: ["open", "cleanup"]
progress after 10 sec: ["open", "finalize"]
progress after 11 sec: ["open", "finalize"]
progress after 12 sec: ["closed", "EVENT_TYPE_WORKFLOW_EXECUTION_COMPLETED"]
closed WF query: ["closed", "EVENT_TYPE_WORKFLOW_EXECUTION_COMPLETED"]
:ok
```

Sample source:
[lib/query_parallel_handler](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/query_parallel_handler)

### Erlang

```erlang
1> query_parallel_handler:start().
progress after 0 sec: ["open",<<"init">>]
progress after 1 sec: ["open",<<"init">>]
progress after 2 sec: ["open",<<"stage_1">>]
progress after 3 sec: ["open",<<"stage_1">>]
progress after 4 sec: ["open",<<"stage_2">>]
progress after 5 sec: ["open",<<"stage_2">>]
progress after 6 sec: ["open",<<"wait_async">>]
progress after 7 sec: ["open",<<"wait_async">>]
progress after 8 sec: ["open",<<"cleanup">>]
progress after 9 sec: ["open",<<"cleanup">>]
progress after 10 sec: ["open",<<"finalize">>]
progress after 11 sec: ["open",<<"finalize">>]
progress after 12 sec: ["closed",
                        <<"EVENT_TYPE_WORKFLOW_EXECUTION_COMPLETED">>]
closed WF query: ["closed",<<"EVENT_TYPE_WORKFLOW_EXECUTION_COMPLETED">>]
ok
```

Sample source:
[src/query_parallel_handler](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/query_parallel_handler)

<!-- tabs-close -->

REMAINDER: Temporal query requests are not persisted in the workflow history hence they are
nondeterministic and cannot be used in a workflow execution branching.
Following example commands will fail workflow execution or behave unexpectedly:
<!-- tabs-open -->

### Elixir

```elixir
await({:query_request, "test_query"}, 10_000)

await_any([{:query_request, "test_query"}, {:marker, :uuid4, :test_marker}])

case await({:query, "test_query"}) do
 {:ok, _} -> start_timer(1_000)
 _ -> start_activity(:echo_activity, [])
end
```

### Erlang

```erlang
await({query_request, "test_query"}, 10_000)

await_any([{query_request, "test_query"}, {marker, uuid4, test_marker}])

case await({query, "test_query"}) of
 {ok, _} -> start_timer(1_000);
 _ -> start_activity(echo_activity, [])
end
```

<!-- tabs-close -->
