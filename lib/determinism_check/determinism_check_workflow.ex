defmodule DeterminismCheck.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @impl true
  def execute(_context, [["echo_activity"]]), do: start_activity(:echo_activity, [[]])
  def execute(_context, [["hello_activity"]]), do: start_activity(:hello_world_activity, [[""]])
  def execute(_context, [["rand_uniform"]]), do: record_rand_uniform()
  def execute(_context, [["uuid4"]]), do: record_uuid4()
  def execute(_context, _Input), do: :ok
end
