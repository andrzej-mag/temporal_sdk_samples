-module(query_parallel_handler_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2,
    cleanup/2,
    progress_query_handler/2,
    handle_query/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

-define(PROGRESS_QUERY, ~"get_progress").

%% Main simplifications assumed for the sake of educational code brevity:
%% * auxiliary hypothetical workflow tasks like initialization or cleanup are mimicked with timers,
%% * activities inputs and results are omitted.
execute(_Context, _Input) ->
    %% init
    set_info(init, [{info_id, progress}]),
    start_execution(progress_query_handler),
    CleanupExecution = start_execution(cleanup),
    start_timer(2_000, [wait]),
    %% run
    set_info(undefined, [{info_id, progress}]),
    A0 = start_activity(echo_activity, [[], 6_000], [{activity_id, stage_0}]),
    start_activity(echo_activity, [[], 2_000], [wait, {activity_id, stage_1}]),
    start_activity(echo_activity, [[], 2_000], [wait, {activity_id, stage_2}]),
    %% wait async activities
    set_info(wait_async, [{info_id, progress}]),
    wait(A0),
    %% cleanup
    wait(CleanupExecution),
    %% finalize
    set_info(finalize, [{info_id, progress}]),
    start_timer(2_000, [wait]).

cleanup(_Context, _Input) ->
    case wait_all([{activity, stage_0}, {activity, stage_1}, {activity, stage_2}]) of
        [#{state := completed}, #{state := completed}, #{state := completed}] ->
            set_info(cleanup, [{info_id, progress}]),
            start_timer(2_000, [wait]);
        _ ->
            set_info(cleanup_and_compensation, [{info_id, progress}]),
            start_timer(20_000, [wait])
    end.

progress_query_handler(_Context, _Input) ->
    case await({query_request, ?PROGRESS_QUERY}) of
        {ok, _} ->
            case is_awaited_any([{info, progress}, {activity, stage_2}, {activity, stage_1}]) of
                {true, [undefined, #{}, _]} -> do_respond_progress_query(stage_2);
                {true, [undefined, noevent, #{}]} -> do_respond_progress_query(stage_1);
                {true, [P, _, _]} -> do_respond_progress_query(P);
                {false, _} -> do_respond_progress_query(undefined)
            end;
        {noevent, _} ->
            ok
    end.

do_respond_progress_query(Answer) ->
    respond_query({query, ?PROGRESS_QUERY}, [wait, {answer, ["open", Answer]}]),
    progress_query_handler(#{}, []).

handle_query(History, #{query_type := ?PROGRESS_QUERY}) ->
    {_EventId, EventType, _EventData, _IgnoredEventData} = lists:last(History),
    #{answer => ["closed", EventType]}.
