-module(workflow_eviction_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2,
    handle_eviction/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

-define(ACTIVITY_COUNT, 3).
-define(ACTIVITY_SLEEP, 500).
-define(URGENT_SIGNAL, "urgent_signal").
-define(EVICTION_HSB, 500_000).

execute(_Context, [[ActivityPayloadSize, HandleEvictionStrategy]]) when
    is_integer(ActivityPayloadSize), is_binary(HandleEvictionStrategy)
->
    set_info(binary_to_existing_atom(HandleEvictionStrategy), [{info_id, handle_eviction_strategy}]),
    ActivityPayload = binary:copy(~"X", ActivityPayloadSize),
    run_blocking_activities(ActivityPayload, ?ACTIVITY_COUNT),
    AwaitResult = temporal_sdk_workflow:await(
        {signal_request, ?URGENT_SIGNAL},
        [evict, {timeout, {2, second}}]
    ),
    run_blocking_activities(ActivityPayload, ?ACTIVITY_COUNT),
    case AwaitResult of
        {ok, #{state := requested}} -> admit_signal(?URGENT_SIGNAL);
        _ -> ok
    end,
    run_blocking_activities(ActivityPayload, ?ACTIVITY_COUNT),
    ok.

run_blocking_activities(Payload, ActivityCount) ->
    [
        #{state := completed} = start_activity(echo_activity, [Payload, ?ACTIVITY_SLEEP], [wait])
     || _ <- lists:seq(1, ActivityCount)
    ].

handle_eviction(#{workflow_info := #{history_size_bytes := HSB}}, _PollIdleTime) ->
    case is_awaited_all([{info, handle_eviction_strategy}, {signal, ?URGENT_SIGNAL}]) of
        {false, [noevent, _]} ->
            throw("Required <handle_eviction_strategy> info not set.");
        {false, [HandleEvictionStrategy, noevent]} ->
            do_handle_eviction(HandleEvictionStrategy, HSB);
        {true, [HandleEvictionStrategy, #{state := admitted}]} ->
            do_handle_eviction(HandleEvictionStrategy, HSB);
        {_, _} ->
            ignore
    end.

do_handle_eviction(always, _HistorySizeBytes) -> evict;
do_handle_eviction(never, _HistorySizeBytes) -> ignore;
do_handle_eviction(_HandleEvictionStrategy, HSB) when HSB > ?EVICTION_HSB -> evict;
do_handle_eviction(_HandleEvictionStrategy, _HistorySizeBytes) -> ignore.
