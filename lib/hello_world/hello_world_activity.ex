defmodule HelloWorld.Activity do
  use TemporalSdk.Activity
  @moduledoc false

  @impl true
  def execute(_context, [[string]]), do: [[String.upcase(string)]]
end
