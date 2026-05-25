-module(parallel_execution).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/parallel_execution.md"}.

-export([
    run/1
]).

-spec run({unicode:chardata(), unicode:chardata(), unicode:chardata(), unicode:chardata()}) ->
    temporal_sdk:workflow_result() | no_return().
run({_, _, _, _} = Input) ->
    {ok, _StartWorkflowRet, WorkflowResult} =
        temporal_sdk:start_workflow(cluster_1, "default", parallel_execution_workflow, [
            await, {input, [tuple_to_list(Input)]}
        ]),
    WorkflowResult.
