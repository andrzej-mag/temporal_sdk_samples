Delete workflow execution command sample.

This sample demonstrates the use of the `delete_workflow/3` Temporal command.

Example is using `get_workflow_state/2` function to get workflow execution state before and after
deletion.
Calling `get_workflow_state/2` after workflow execution is deleted returns a gRPC error:
`"workflow execution not found ..."`.

Example run:

<!-- tabs-open -->

### Elixir

```elixir
iex(1)> WorkflowDelete.run()
WF execution state before deletion:
  {:ok, :running}

WF execution state after deletion:
  {:error, "workflow execution not found for workflow ID \"Elixir.WorkflowTerminate.Workflow/3ac9bbf8-df62-4560-a3c5-5d6aa9d3a6b9\" and run ID \"019e016c-9ec2-7515-b7ea-e74e9b498ac8\""}

:ok
```

Sample source:
[lib/workflow_delete](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/workflow_delete)

### Erlang

```erlang
1> workflow_delete:run().
WF execution state before deletion:
  {ok,running}

WF execution state after deletion:
  {error,<<"workflow execution not found for workflow ID \"workflow_terminate_workflow/c7dc7fa4-946e-46dd-a2a2-c0b663201964\" and run ID \"019e016d-a87e-76b1-9be4-c12c994979bf\"">>}

ok
```

Sample source:
[src/workflow_delete](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/workflow_delete)

<!-- tabs-close -->
