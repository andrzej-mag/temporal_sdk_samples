defmodule WorkflowTerminate.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @impl true
  def execute(_context, _input), do: start_timer(5_000, [:wait])
end
