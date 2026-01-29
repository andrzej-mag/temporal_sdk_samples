-module(payload_codec).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/payload_codec.md"}.

-export([
    start_default/0,
    start_encrypted/0
]).

start_default() ->
    temporal_sdk:start_workflow(cluster_1, "default", hello_world_workflow, [
        wait, {input, [[~b"from Temporal"]]}, {workflow_id, "plain"}
    ]).

start_encrypted() ->
    temporal_sdk:start_workflow(cluster_1_enc, "encrypted", hello_world_workflow, [
        wait, {input, [[~b"from Temporal"]]}, {workflow_id, "encrypted"}
    ]).
