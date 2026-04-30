-module(workflow_eviction).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/workflow_eviction.md"}.

-export([
    run/2
]).
-export([
    maybe_attach_telemetry/0,
    handle_eviction_log/4
]).

-define(URGENT_SIGNAL, "urgent_signal").

-spec run(
    ActivityPayloadSize :: pos_integer(), HandleEvictionStrategy :: always | custom | never | atom()
) -> ok | no_return().
run(ActivityPayloadSize, HandleEvictionStrategy) ->
    maybe_attach_telemetry(),
    {ok, #{workflow_execution := WE}} =
        temporal_sdk:start_workflow(cluster_1, "default", workflow_eviction_workflow, [
            {input, [[ActivityPayloadSize, atom_to_binary(HandleEvictionStrategy)]]}
        ]),
    timer:sleep(2_000),
    temporal_sdk:signal_workflow(cluster_1, WE, ?URGENT_SIGNAL),
    {ok, {completed, #{}}} = temporal_sdk:await_workflow(cluster_1, WE),
    ok.

-doc false.
maybe_attach_telemetry() ->
    case telemetry:list_handlers([temporal_sdk, workflow, executor, stop]) of
        [] ->
            telemetry:attach_many(
                ?MODULE,
                [
                    [temporal_sdk, workflow, executor, stop],
                    [temporal_sdk, poller, execute, stop]
                ],
                fun ?MODULE:handle_eviction_log/4,
                []
            );
        _ ->
            ok
    end.

-doc false.
handle_eviction_log(
    [temporal_sdk, workflow, executor, stop] = E,
    #{},
    #{closing_state := CS, workflow_info := #{event_id := EId}},
    []
) ->
    io:fwrite("~p: ~b -> ~p~n", [E, EId, CS]);
handle_eviction_log(
    [temporal_sdk, poller, execute, stop] = E,
    #{},
    #{worker_type := sticky_queue, task_execute_status := TES},
    []
) ->
    io:fwrite("~p: ~p~n", [E, TES]);
handle_eviction_log(_Event, _Measurements, _Metadata, _HandlerConfig) ->
    ok.
