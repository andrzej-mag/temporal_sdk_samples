-module(eviction_parallel_handler_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2,
    eviction_handler/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

-define(ACTIVITY_COUNT, 3).
-define(ACTIVITY_SLEEP, 500).
-define(URGENT_SIGNAL, "urgent_signal").
-define(EVICTION_HSB, 500_000).

execute(_Context, [[ActivityPayloadSize, EvictionStrategy]]) when
    is_integer(ActivityPayloadSize), is_binary(EvictionStrategy)
->
    start_execution(eviction_handler, {binary_to_existing_atom(EvictionStrategy), 1}),
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

eviction_handler(#{}, {EvictionStrategy, EventId}) ->
    case await({event, {EventId, '_', '_', '_'}}) of
        {noevent, noevent} ->
            ok;
        {ok, #{event_id := EventId, attributes := #{history_size_bytes := HSB}}} ->
            maybe_evict(EvictionStrategy, HSB),
            eviction_handler(#{}, {EvictionStrategy, EventId + 1});
        {ok, #{event_id := EventId}} ->
            eviction_handler(#{}, {EvictionStrategy, EventId + 1})
    end.

maybe_evict(always, _HistorySizeBytes) -> do_evict();
maybe_evict(custom, HistorySizeBytes) when HistorySizeBytes > ?EVICTION_HSB -> do_evict();
maybe_evict(_EvictionStrategy, _HistorySizeBytes) -> ok.

do_evict() ->
    case is_awaited({signal, ?URGENT_SIGNAL}) of
        {true, #{state := requested}} -> ok;
        _ -> evict_workflow()
    end.
