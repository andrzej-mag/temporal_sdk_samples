-module(awaitable_event).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/awaitable_event.md"}.

-export([
    run/1
]).

-spec run(WorkerStartDelay :: non_neg_integer()) -> ok.
run(WorkerStartDelay) ->
    spawn(fun() -> start_activity_worker(WorkerStartDelay) end),
    temporal_sdk:start_workflow(cluster_1, "default", awaitable_event_workflow, [wait]),
    ok.

start_activity_worker(WorkerStartDelay) ->
    case temporal_sdk_worker:is_started(cluster_1, activity, awaitable_event_activity) of
        false ->
            timer:sleep(WorkerStartDelay),
            io:fwrite("Start activity worker.~n", []),
            {ok, #{}} = temporal_sdk_worker:start(cluster_1, activity, [
                {task_queue, "awaitable_event"}, {worker_id, awaitable_event_activity}
            ]);
        true ->
            io:fwrite("Activity worker already started.~n", [])
    end.
