defmodule ReplayTest.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @impl true
  def execute(_context, _input) do
    start_timer(1)
    start_activity(:echo_activity, [["hello world"]])
    record_uuid4()
  end
end
