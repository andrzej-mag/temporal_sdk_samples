defmodule Saga.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  # Assumption: parallel deposit/withdraw/other operations are supported.
  @impl true
  def execute(_context, transfer_details) do
    opts = [heartbeat_timeout: {10, :second}]
    a_deposit = start_activity(Saga.Activity.Deposit, transfer_details, opts)
    a_withdraw = start_activity(Saga.Activity.Withdraw, transfer_details, opts)
    a_other = start_activity(Saga.Activity.Other, transfer_details, opts)
    # Our bank doesn't accept withdrawals today:
    cancel_activity(a_withdraw)

    case wait_all([a_deposit, a_withdraw, a_other]) do
      [%{state: :completed}, %{state: :completed}, %{state: :completed}] ->
        :ok

      [%{state: s_d}, %{state: s_w}, %{state: s_o}] ->
        compensation_state = %{deposit: s_d, withdraw: s_w, other: s_o}
        start_activity(Saga.Activity.Compensation, [compensation_state, transfer_details])
    end
  end
end
