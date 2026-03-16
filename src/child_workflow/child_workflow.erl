-module(child_workflow).

% elp:ignore W0012 W0040 E1599
-moduledoc {file, "../../docs/child_workflow.md"}.

-export([
    run/1
]).

-spec run(ChildWorkflowOutcome :: complete | cancel | fail | invalid | atom()) ->
    temporal_sdk:workflow_result() | no_return().
run(ChildWorkflowOutcome) when is_atom(ChildWorkflowOutcome) ->
    case
        temporal_sdk:start_workflow(
            cluster_1, "default", child_workflow_workflow, [
                wait, {input, [[atom_to_binary(ChildWorkflowOutcome)]]}
            ]
        )
    of
        {S, _} when S =:= error; S =:= ok -> throw("Unexpected result.");
        {_StartWorkflowRet, WorkflowResult} -> WorkflowResult
    end.
