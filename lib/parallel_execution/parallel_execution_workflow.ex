defmodule ParallelExecution.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @impl true
  def execute(_context, [[i1, i2, i3, i4]]) do
    # Parallel executions require unique :execution_id.
    # When calling start_execution/3, by default, :execution_id is set to the function name, hence we
    # assign a unique :execution_id manually here to fulfill uniqueness requirement.
    e1 = start_execution(:execution_parallel, [i1, i2], execution_id: :e1)
    e2 = start_execution(:execution_parallel, [i3, i4], execution_id: :e2)
    [%{result: e1r}, %{result: e2r}] = wait_all([e1, e2])
    set_workflow_result([List.flatten([e1r, e2r])])
  end

  def execution_parallel(_context, [i1, i2]) do
    a1 = start_activity(EchoActivity, [i1])
    a2 = start_activity(EchoActivity, [i2])
    [%{result: a1r}, %{result: a2r}] = wait_all([a1, a2])
    # Unique :execution_id can be automatically generated with :awaitable_id.
    %{result: r} =
      start_execution(:execution_nested, [a1r, a2r], [:wait, awaitable_id: :e_nested])

    r
  end

  def execution_nested(_context, [i1, i2]) do
    a1 = start_activity(HelloWorld.Activity, [i1])
    a2 = start_activity(HelloWorld.Activity, [i2])
    [%{result: [[a1r]]}, %{result: [[a2r]]}] = wait_all([a1, a2])
    [a1r, a2r]
  end
end
