Virtual cluster with custom Temporal payload converter codec sample.

Example uses two SDK cluster configurations:

- "cluster_1" which might be considered as a "default" SDK cluster with the default Temporal payload
   converter,
- "cluster_1_enc" - a virtual SDK cluster with a custom Temporal payload converter configuration.

Both SDK clusters connect to the same Temporal server instance at the default `localhost:7233` address.

Example custom payload converter codec encodes and encrypts Temporal payload data in three steps:

1. Encode Erlang term data to binary with `erlang:term_to_binary/2`.
2. Encrypt binary data with `crypto:crypto_one_time/5`,
3. Encode binary with `base64:encode/1`.

Example provides two functions executing "Hello World" sample workflow against both SDK cluster
configurations.

Example run:

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> PayloadConverter.start_default()
HELLO WORLD from Temporal

{%{
   started: true,
   request_id: ~c"cluster_1-Elixir.HelloWorld.Workflow-344d3e9f-377e-4f81-a899-7af461bb4e93",
   workflow_execution: %{
     workflow_id: "plain",
     run_id: "019c04f6-9d50-7429-84b4-4fcace23450f"
   }
 },
 {:completed,
  %{result: [], workflow_task_completed_event_id: 13, new_execution_run_id: ""}}}
iex(2)> PayloadConverter.start_encrypted()
HELLO WORLD from Temporal

{%{
   started: true,
   request_id: ~c"cluster_1_enc-Elixir.HelloWorld.Workflow-cff25cbc-71b9-4b65-983c-633f6622eb87",
   workflow_execution: %{
     workflow_id: "encrypted",
     run_id: "019c04f6-be29-778b-8075-2bfca220640d"
   }
 },
 {:completed,
  %{result: [], workflow_task_completed_event_id: 13, new_execution_run_id: ""}}}
```

Sample source:
[lib/payload_converter](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/payload_converter)

### Erlang

```erlang
1> payload_converter:start_default().
HELLO WORLD from Temporal

{#{started => true,
   request_id =>
       "cluster_1-hello_world_workflow-b02db120-db19-442c-8e30-e70f484d8088",
   workflow_execution =>
       #{workflow_id => "plain",
         run_id => <<"019c04d5-1cf9-7b8c-a543-c23d633146d1">>}},
 {completed,#{result => [],workflow_task_completed_event_id => 13,
              new_execution_run_id => <<>>}}}
2> payload_converter:start_encrypted().
HELLO WORLD from Temporal

{#{started => true,
   request_id =>
       "cluster_1_enc-hello_world_workflow-d23143ed-f1e0-4515-8355-347c50abdc3b",
   workflow_execution =>
       #{workflow_id => "encrypted",
         run_id => <<"019c04d5-35d4-73e9-a8fd-43d0a6d327a2">>}},
 {completed,#{result => [],workflow_task_completed_event_id => 13,
              new_execution_run_id => <<>>}}}
```

Sample source:
[src/payload_converter](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/payload_converter)

<!-- tabs-close -->

Payloads for both plain and encrypted workflow executions can be compared using the Temporal Web UI.

See also:

- [Temporal Codec Server](https://docs.temporal.io/codec-server),
- `temporal_sdk_api:from_payload_mapper/5` and `temporal_sdk_api:to_payload_mapper/5`.
