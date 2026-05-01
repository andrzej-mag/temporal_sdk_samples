Terminate workflow execution command sample.

This sample demonstrates the use of the `terminate_workflow/3` Temporal command.
Sample uses the telemetry event logger defined in the `m:workflow_eviction` module.

Example run:

<!-- tabs-open -->

### Elixir

```elixir
iex(1)> WorkflowTerminate.run()
{:terminated,
 %{
   reason: "test termination",
   identity: "wkst/nonode@nohost/cluster_1/<0.987.0>"
 }}
# after approximately 60 seconds:
[temporal_sdk,workflow,executor,stop]: 3 -> terminated
```

Sample source:
[lib/workflow_terminate](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/workflow_terminate)

### Erlang

```erlang
1> workflow_terminate:run().
{terminated,#{reason => <<"test termination">>,
              identity => <<"wkst/nonode@nohost/cluster_1/<0.498.0>">>}}
%% after approximately 60 seconds:
[temporal_sdk,workflow,executor,stop]: 3 -> terminated
```

Sample source:
[src/workflow_terminate](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/workflow_terminate)

<!-- tabs-close -->
