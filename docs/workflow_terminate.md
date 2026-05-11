Terminate workflow execution command sample.

This sample demonstrates the use of the `temporal_sdk:terminate_workflow/3` Temporal command.
The sample attaches the telemetry event logger defined in the `m:workflow_eviction` module.
When the termination command is executed, SDK evicts workflow execution, and the workflow executor's
`closing_state` is set to `{external_evict, terminated}`.

Example run:

<!-- tabs-open -->

### Elixir

```elixir
iex(1)> WorkflowTerminate.run()
[temporal_sdk,workflow,executor,stop]: 3 -> {external_evict,terminated}
{:terminated,
 %{
   reason: "test termination",
   identity: "wkst/nonode@nohost/cluster_1/<0.997.0>"
 }}
```

Sample source:
[lib/workflow_terminate](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/workflow_terminate)

### Erlang

```erlang
1> workflow_terminate:run().
[temporal_sdk,workflow,executor,stop]: 3 -> {external_evict,terminated}
{terminated,#{reason => <<"test termination">>,
              identity => <<"wkst/nonode@nohost/cluster_1/<0.359.0>">>}}
```

Sample source:
[src/workflow_terminate](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/workflow_terminate)

<!-- tabs-close -->
