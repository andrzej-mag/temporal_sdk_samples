defmodule AwaitableEvent.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @impl true
  def execute(_context, _input) do
    a_start =
      start_activity(:echo_activity, [["Activity completed."]],
        task_queue: "awaitable_event",
        awaitable_event: :start
      )

    case await(a_start, 1000) do
      {:noevent, %{}} -> IO.puts("WARN: Activity NOT started within 1000 msec timeout")
      {:ok, %{}} -> IO.puts("WARN: Activity NOT started within 1000 msec timeout")
    end

    a_close = :erlang.setelement(1, a_start, :activity)
    %{state: :completed, result: [[r]]} = wait(a_close)
    IO.puts(r)
  end
end
