-module(otel_sample_child_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

execute(Context, _Input) ->
    #{workflow_info := #{opentelemetry_baggage := _Baggage}} = Context,
    ok.
