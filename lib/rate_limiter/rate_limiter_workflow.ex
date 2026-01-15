defmodule RateLimiter.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @activities_count 10

  @impl true
  def execute(_context, _input) do
    activities =
      for count <- 1..@activities_count,
          do: start_activity(RateLimiter.Activity, [count], task_queue: "limited_tq")

    wait_all(activities)
  end
end
