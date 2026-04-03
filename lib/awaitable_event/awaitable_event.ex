defmodule AwaitableEvent do
  @external_resource "docs/awaitable_event.md"
  @moduledoc TemporalSdk.Utils.exdoc!("docs/awaitable_event.md")

  @spec run(worker_start_delay :: non_neg_integer()) :: :ok
  def run(worker_start_delay) do
    spawn(fn -> start_activity_worker(worker_start_delay) end)
    TemporalSdk.start_workflow(:cluster_1, "default", AwaitableEvent.Workflow, [:wait])
    :ok
  end

  @doc false
  def start_activity_worker(worker_start_delay) do
    case TemporalSdk.Worker.is_started(:cluster_1, :activity, :awaitable_event_activity) do
      false ->
        Process.sleep(worker_start_delay)
        IO.puts("Start activity worker.")

        {:ok, %{}} =
          TemporalSdk.Worker.start(:cluster_1, :activity,
            task_queue: "awaitable_event",
            worker_id: :awaitable_event_activity
          )

      true ->
        IO.puts("Activity worker already started.")
    end
  end
end
