-module(hello_world).

% elp:ignore W0012 W0040
-moduledoc """
Hello world example.

Example workflow execution:
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
""".

-export([
    start/0
]).

start() ->
    temporal_sdk:start_workflow(cluster_1, "default", hello_world_workflow, [
        wait, {input, ["from Temporal"]}
    ]).
