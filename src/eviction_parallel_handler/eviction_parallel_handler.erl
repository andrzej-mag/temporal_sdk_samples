-module(eviction_parallel_handler).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/eviction_parallel_handler.md"}.

-export([
    run/2
]).

-define(URGENT_SIGNAL, "urgent_signal").

-spec run(
    ActivityPayloadSize :: pos_integer(), EvictionStrategy :: always | custom | never | atom()
) -> ok | no_return().
run(ActivityPayloadSize, EvictionStrategy) ->
    workflow_eviction:maybe_attach_telemetry(),
    {ok, #{workflow_execution := WE}} =
        temporal_sdk:start_workflow(cluster_1, "default", eviction_parallel_handler_workflow, [
            {input, [[ActivityPayloadSize, atom_to_binary(EvictionStrategy)]]}
        ]),
    timer:sleep(2_000),
    temporal_sdk:signal_workflow(cluster_1, WE, ?URGENT_SIGNAL),
    {ok, {completed, #{}}} = temporal_sdk:await_workflow(cluster_1, WE),
    ok.
