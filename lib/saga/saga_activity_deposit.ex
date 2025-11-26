defmodule Saga.Activity.Deposit do
  use TemporalSdk.Activity
  @moduledoc false

  @impl true
  def execute(_context, _input) do
    Process.sleep(1_000)
    ["deposit"]
  end

  @impl true
  def handle_heartbeat(_context), do: :heartbeat

  @impl true
  def handle_cancel(%{cancel_requested: true}), do: {:cancel, ["details"]}
  def handle_cancel(_context), do: :ignore
end
