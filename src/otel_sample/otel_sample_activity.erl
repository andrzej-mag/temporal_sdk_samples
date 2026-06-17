-module(otel_sample_activity).

% elp:ignore W0012 W0040
-moduledoc false.

-export([execute/2]).

-include_lib("temporal_sdk/include/activity.hrl").
-include_lib("opentelemetry_api/include/otel_tracer.hrl").

execute(_Context, _Input) ->
    Baggage = otel_baggage:get_all(),
    BaggageAttr = maps:map(fun(_K, {V, _Meta}) -> V end, Baggage),
    ?set_attributes(BaggageAttr),
    ?with_span(~"my_activity_span", #{attributes => BaggageAttr}, fun(_SpanCtx) ->
        timer:sleep(20)
    end),
    [~"ok"].
