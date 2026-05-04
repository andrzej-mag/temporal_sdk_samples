defmodule WorkflowCancelParallel.Activity do
  use TemporalSdk.Activity
  @moduledoc false

  @impl true
  def execute(_context, [activities]) when is_list(activities) do
    IO.puts("Running cleanup activity. Canceled activities count: #{length(activities)}.")
    ["ok"]
  end
end
