defmodule RateLimiter.Activity do
  use TemporalSdk.Activity
  @moduledoc false

  @impl true
  def execute(_context, [activity_count]) when is_integer(activity_count) do
    IO.puts("Executing activity number #{activity_count}")
    Process.sleep(1_000)
    ["ok"]
  end
end
