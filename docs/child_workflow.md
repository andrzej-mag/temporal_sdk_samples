Child workflow example.

This sample workflow starts an activity and a child workflow in parallel. The child workflow’s
behavior depends on its input: it may be canceled, fail, or start an activity before completing.
The parent workflow’s final result depends on the closing states of both the activity and the
child workflow. If both complete successfully, the parent workflow succeeds; otherwise, it is
failed.

Example execution:

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> ChildWorkflow.run(:complete)
{:completed,
 %{
   result: [["HELLO WORLD", "from temporal"]],
   workflow_task_completed_event_id: 19,
   new_execution_run_id: ""
 }}
iex(2)> ChildWorkflow.run(:cancel)
{:failed,
 %{
   failure: %{
     message: "<<\"Error.\">>",
     source: "",
     stack_trace: "\#{activity_state => completed,child_workflow_state => canceled}"
   },
   workflow_task_completed_event_id: 19,
   new_execution_run_id: "",
   retry_state: :RETRY_STATE_RETRY_POLICY_NOT_SET
 }}
iex(3)> ChildWorkflow.run(:fail)
{:failed,
 %{
   failure: %{
     message: "<<\"Error.\">>",
     source: "",
     stack_trace: "\#{activity_state => completed,child_workflow_state => failed}"
   },
   workflow_task_completed_event_id: 19,
   new_execution_run_id: "",
   retry_state: :RETRY_STATE_RETRY_POLICY_NOT_SET
 }}
iex(4)> ChildWorkflow.run(:invalid)
{:failed,
 %{
   failure: %{
     message: "<<\"Invalid data.\">>",
     source: "",
     stack_trace: "\#{activity_data => [[<<\"HELLO WORLD\">>]],child_workflow_data => [12345]}"
   },
   workflow_task_completed_event_id: 19,
   new_execution_run_id: "",
   retry_state: :RETRY_STATE_RETRY_POLICY_NOT_SET
 }}
```

Sample source:
[lib/child_workflow](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/child_workflow)

### Erlang

```erlang
1> child_workflow:run(complete).
{completed,#{result =>
                 [[<<"HELLO WORLD">>,<<"from temporal">>]],
             workflow_task_completed_event_id => 19,
             new_execution_run_id => <<>>}}
2> child_workflow:run(cancel).
{failed,#{failure =>
              #{message => <<"Error.">>,source => <<>>,
                stack_trace =>
                    <<"#{activity_state => completed,child_workflow_state => canceled}">>},
          workflow_task_completed_event_id => 19,
          new_execution_run_id => <<>>,
          retry_state => 'RETRY_STATE_RETRY_POLICY_NOT_SET'}}
3> child_workflow:run(fail).
{failed,#{failure =>
              #{message => <<"Error.">>,source => <<>>,
                stack_trace =>
                    <<"#{activity_state => completed,child_workflow_state => failed}">>},
          workflow_task_completed_event_id => 19,
          new_execution_run_id => <<>>,
          retry_state => 'RETRY_STATE_RETRY_POLICY_NOT_SET'}}
4> child_workflow:run(invalid).
{failed,#{failure =>
              #{message => <<"Invalid data.">>,source => <<>>,
                stack_trace =>
                    <<"#{activity_data => [[<<\"HELLO WORLD\">>]],child_workflow_data => [12345]}">>},
          workflow_task_completed_event_id => 19,
          new_execution_run_id => <<>>,
          retry_state => 'RETRY_STATE_RETRY_POLICY_NOT_SET'}}
```

Sample source:
[src/child_workflow](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/child_workflow)

<!-- tabs-close -->
