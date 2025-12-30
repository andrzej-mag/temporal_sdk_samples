defmodule Saga.Activity.Compensation do
  use TemporalSdk.Activity
  @moduledoc false

  @impl true
  def execute(_context, [compensation_state, _transfer_details]) do
    IO.puts("""
    Compensation activity started with:
        #{inspect(compensation_state)}
    """)

    Process.sleep(100)
    ["compensation"]
  end
end
