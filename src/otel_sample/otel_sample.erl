-module(otel_sample).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/otel_sample.md"}.

-export([
    run/0
]).

run() -> temporal_sdk:start_workflow(cluster_1, "default", otel_sample_workflow).
