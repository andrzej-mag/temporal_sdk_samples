Delete workflow execution command sample.

This sample demonstrates the use of the `temporal_sdk:delete_workflow/3` Temporal command.
Example is using `temporal_sdk:get_workflow_state/2` function to get workflow execution state before
and after deletion. Calling `temporal_sdk:get_workflow_state/2` after workflow execution is deleted
returns a gRPC error: `"workflow execution not found ..."`.

Additionally, sample attaches the telemetry event logger defined in the `m:workflow_eviction` module.
When the deletion command is executed, SDK evicts workflow execution, and the workflow executor's
`closing_state` is set to `{external_evict, deleted}`.

Example run:

<!-- tabs-open -->

### Elixir

```elixir
iex(1)> WorkflowDelete.run()
WF execution state before deletion:
  {:ok, :running}

[temporal_sdk,workflow,executor,stop]: 3 -> {external_evict,deleted}

WF execution state after deletion:
  {:error, "workflow execution not found for workflow ID \"Elixir.WorkflowTerminate.Workflow/4e528d5e-ca9d-4882-b93a-9d163477209d\" and run ID \"019e16d0-8ce7-776d-bbd4-53f59bb8c754\""}

:ok
```

Sample source:
[lib/workflow_delete](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/workflow_delete)

### Erlang

```erlang
1> workflow_delete:run().
WF execution state before deletion:
  {ok,running}

[temporal_sdk,workflow,executor,stop]: 3 -> {external_evict,deleted}

WF execution state after deletion:
  {error,<<"workflow execution not found for workflow ID \"workflow_terminate_workflow/7bb27ec8-55fe-44bf-99a1-664991635de7\" and run ID \"019e16d2-e814-711b-8bea-2e694966acf5\"">>}

ok
```

Sample source:
[src/workflow_delete](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/workflow_delete)

<!-- tabs-close -->
