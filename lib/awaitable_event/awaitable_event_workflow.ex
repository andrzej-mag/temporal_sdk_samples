defmodule AwaitableEvent.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @impl true
  def execute(_context, _input) do
    {:activity_start, a_id} =
      a_start =
      start_activity(EchoActivity, [["Activity completed."]],
        task_queue: "awaitable_event",
        awaitable_event: :start
      )

    {await_status, %{}} = await(a_start, 1_000)
    %{is_replaying: is_replaying} = workflow_info()

    case {is_replaying, await_status} do
      {true, _} ->
        :ok

      {false, :noevent} ->
        IO.puts("WARN: Activity not started within 1000 msec timeout or nonexistent activity.")

      {false, :ok} ->
        IO.puts("INFO: Activity started within 1000 msec timeout.")
    end

    a_close = {:activity, a_id}
    %{state: :completed, result: [[r]]} = wait(a_close)
    IO.puts(r)
  end
end
