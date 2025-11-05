-module(saga_workflow).

% elp:ignore W0012 W0040
-moduledoc false.

-export([
    execute/2
]).

-include_lib("temporal_sdk/include/workflow.hrl").

%% Assumption: parallel deposit/withdraw/other operations are supported.
execute(_Context, TransferDetails) ->
    Opts = [{heartbeat_timeout, {10, second}}],
    ADeposit = start_activity(saga_activity_deposit, TransferDetails, Opts),
    AWithdraw = start_activity(saga_activity_withdraw, TransferDetails, Opts),
    AOther = start_activity(saga_activity_other, TransferDetails, Opts),
    cancel_activity(AWithdraw),
    case wait_all([ADeposit, AWithdraw, AOther]) of
        [#{state := completed}, #{state := completed}, #{state := completed}] ->
            ok;
        [#{state := SD}, #{state := SW}, #{state := SO}] ->
            CompensationState = #{deposit => SD, withdraw => SW, other => SO},
            start_activity(saga_activity_compensation, [CompensationState, TransferDetails])
    end.
