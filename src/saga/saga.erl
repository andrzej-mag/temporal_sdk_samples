-module(saga).

% elp:ignore W0012 W0040
-moduledoc """
Saga pattern example.

Example workflow execution:
```erlang
1> saga:start().
Compensation activity started with:
    #{<<"deposit">> => <<"completed">>,<<"other">> => <<"failed">>,
      <<"withdraw">> => <<"canceled">>}

{#{started => true,
   request_id =>
       "cluster_1-saga_workflow-6fb23eee-bbe2-4ebd-9d4a-13ac2af91de4",
   workflow_execution =>
       #{workflow_id =>
             "saga_workflow/25ff0aa8-e337-4453-b417-33409f7b684c",
         run_id => <<"019a2163-e32c-7394-83d3-cfa10fbf0620">>}},
 {completed,#{result => [],workflow_task_completed_event_id => 28,
              new_execution_run_id => <<>>}}}
```

Corresponding other SDKs implementations:
  * [Go SDK](https://github.com/temporalio/samples-go/tree/main/saga),
  * [Ruby SDK](https://github.com/temporalio/samples-ruby/tree/main/saga).
""".

-export([
    start/0
]).

start() -> temporal_sdk:start_workflow(cluster_1, "default", saga_workflow, [wait]).
