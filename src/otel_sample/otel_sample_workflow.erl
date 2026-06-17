-module(otel_sample_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

execute(_Context, _Input) ->
    #{value := UUId} = record_uuid4([wait]),
    case is_binary(UUId) of
        true -> otel_set_baggage(~"uuid", UUId, [{~"meta_key", ~"meta_val"}]);
        false -> otel_set_baggage(~"uuid", ~"invalid", [])
    end,
    otel_set_attributes(#{attr_key => attr_value}),
    start_activity(otel_sample_activity, [], [wait]),
    otel_add_event(workflow_event, #{event_key => event_val}),
    start_child_workflow("default", otel_sample_child_workflow).
