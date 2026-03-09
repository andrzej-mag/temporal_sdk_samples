Workflow execution cancellation sample.

Example run:

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> WorkflowCancel.start()
{:ok,
 {:canceled,
  %{details: [["CANCEL ALL requested."]], workflow_task_completed_event_id: 15}}}
```

### Erlang

```erlang
1> workflow_cancel:start().
{ok,{canceled,#{details => [[<<"CANCEL ALL requested.">>]],
                workflow_task_completed_event_id => 15}}}
```
<!-- tabs-close -->
