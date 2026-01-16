defmodule QueryParallelHandler do
  @external_resource "docs/query_parallel_handler.md"
  @moduledoc File.read!("docs/query_parallel_handler.md")

  @progress_query <<"get_progress">>

  def start() do
    cluster = :cluster_1

    {:ok, %{workflow_execution: we}} =
      TemporalSdk.start_workflow(cluster, "default", QueryParallelHandler.Workflow)

    run_query(cluster, we, 0)
  end

  defp run_query(cluster, we, count) when count < 13 do
    qr = TemporalSdk.Service.query_workflow(cluster, we, @progress_query)
    inspect_query_response(qr, "progress after #{count} sec")
    Process.sleep(1_000)
    run_query(cluster, we, count + 1)
  end

  defp run_query(cluster, we, _count) do
    TemporalSdk.await_workflow(cluster, we)
    qr = TemporalSdk.Service.query_workflow(cluster, we, @progress_query)
    inspect_query_response(qr, "closed WF query")
  end

  defp inspect_query_response({:ok, %{query_result: r}}, header),
    do: IO.puts("#{header}: #{inspect(r)}")

  defp inspect_query_response(err, header),
    do: IO.puts("#{header}: #{inspect(err)}")
end
