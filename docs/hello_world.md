Hello world example.

Example workflow execution:

<!-- tabs-open -->

### Elixir

```elixir
iex(1)> HelloWorld.start()
HELLO WORLD from Temporal

{%{
   started: true,
   request_id: ~c"cluster_1-Elixir.HelloWorld.Workflow-8be2da91-759f-4d13-ac3a-73380a403104",
   workflow_execution: %{
     workflow_id: ~c"Elixir.HelloWorld.Workflow/6d663d47-0e49-4ca8-b0fe-2949d1640c00",
     run_id: "019a7d47-17d2-7d74-a158-2d7f02c3f7ce"
   }
 },
 {:completed,
  %{result: [], workflow_task_completed_event_id: 13, new_execution_run_id: ""}}}
```

Sample source:
[lib/hello_world](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/hello_world)

### Erlang

```erlang
1> hello_world:start().
HELLO WORLD from Temporal

{#{started => true,
   request_id =>
       "cluster_1-hello_world_workflow-dd998c98-60a0-4a6a-935f-e352d7eb5eba",
   workflow_execution =>
       #{workflow_id =>
             "hello_world_workflow/0d01826e-287b-46c4-ac44-94db5557fa0a",
         run_id => <<"019a39f2-eca3-7afa-a891-d9f1551cfedd">>}},
 {completed,#{result => [],workflow_task_completed_event_id => 13,
              new_execution_run_id => <<>>}}}
```

Sample source:
[src/hello_world](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/hello_world)

<!-- tabs-close -->
