Simple signaling example.

Example run:

<!-- tabs-open -->

### Elixir

```elixir
iex(1)> SignalSimple.start_then_signal()
{:completed,
 %{
   result: ["Cancel requested. Activity canceled."],
   workflow_task_completed_event_id: 17,
   new_execution_run_id: ""
 }}
iex(2)> SignalSimple.start_with_signal()
{%{
   started: true,
   request_id: ~c"cluster_1-Elixir.SignalSimple.Workflow-086e9c0c-2847-40c0-ba64-d36ac9079b2d",
   workflow_execution: %{
     workflow_id: ~c"Elixir.SignalSimple.Workflow/131005d7-e05f-45c1-8469-81f4d911a8c2",
     run_id: "5e6bd56e-94b1-47b4-a139-b931f7e3e3d6"
   }
 },
 {:completed,
  %{
    result: ["Cancel requested. Activity canceled."],
    workflow_task_completed_event_id: 13,
    new_execution_run_id: ""
  }}}
```

Sample source:
[lib/signal_simple](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/signal_simple)

### Erlang

```erlang
1> signal_simple:start_then_signal().
{completed,#{result =>
                 ["Cancel requested. Activity canceled."],
             workflow_task_completed_event_id => 17,
             new_execution_run_id => <<>>}}
2> signal_simple:start_with_signal().
{#{started => true,
   request_id =>
       "cluster_1-signal_simple_workflow-554574f8-5f92-4b9a-a350-4f46bfc9aef4",
   workflow_execution =>
       #{workflow_id =>
             "signal_simple_workflow/d5610105-0f1c-4c49-846d-39153e8099d9",
         run_id => <<"804180a3-7c8c-4787-a34b-f4d0a1419137">>}},
 {completed,#{result =>
                  ["Cancel requested. Activity canceled."],
              workflow_task_completed_event_id => 13,
              new_execution_run_id => <<>>}}}
```

Sample source:
[src/signal_simple](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/signal_simple)

<!-- tabs-close -->
