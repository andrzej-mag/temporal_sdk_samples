defmodule RateLimiter do
  @external_resource "docs/rate_limiter.md"
  @moduledoc TemporalSdk.Utils.exdoc!("docs/rate_limiter.md")

  @worker_id "limited_worker"
  @frequency_limit 1_000

  def start_worker() do
    TemporalSdk.Worker.start(
      :cluster_1,
      :activity,
      worker_id: @worker_id,
      task_queue: "limited_tq",
      task_poller_pool_size: 1
    )
  end

  def terminate_worker(), do: TemporalSdk.Worker.terminate(:cluster_1, :activity, @worker_id)

  def get_worker_concurrency_limit() do
    case TemporalSdk.Worker.get_limiter_config(:cluster_1, :activity, @worker_id) do
      {:ok, %{limits: %{worker: %{activity_regular: {l, _}}}}} -> {:ok, l}
      {:ok, _} -> :undefined
      err -> err
    end
  end

  def set_worker_concurrency_limit(concurrency_limit) when is_integer(concurrency_limit) do
    TemporalSdk.Worker.set_limiter_config(
      :cluster_1,
      :activity,
      @worker_id,
      %{:limits => %{:worker => %{:activity_regular => {concurrency_limit, @frequency_limit}}}}
    )
  end

  def start() do
    start_time = System.system_time(:millisecond)

    case TemporalSdk.start_workflow(:cluster_1, "default", RateLimiter.Workflow, [:wait]) do
      {%{}, {:completed, %{}}} ->
        duration = System.system_time(:millisecond) - start_time
        IO.puts("Workflow completed in #{duration} msec.")

      err ->
        err
    end
  end
end
