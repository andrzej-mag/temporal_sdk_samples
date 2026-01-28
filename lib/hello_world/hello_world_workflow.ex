defmodule HelloWorld.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @impl true
  def execute(_context, input) do
    a1 = start_activity(HelloWorld.Activity, [["hello"]])
    a2 = start_activity(HelloWorld.Activity, [["world"]])
    [%{result: a1_result}, %{result: a2_result}] = wait_all([a1, a2])
    IO.puts("#{a1_result} #{a2_result} #{input} \n")
  end
end
