defmodule ReplayTest do
  @external_resource "docs/replay_test.md"
  @moduledoc TemporalSdk.Utils.exdoc!("docs/replay_test.md")

  def replay_from_file() do
    TemporalSdk.replay_file(
      :cluster_1,
      ReplayTest.Workflow,
      "src/replay_test/replay_test_workflow.json"
    )
  end

  def replay_from_file_nde() do
    TemporalSdk.replay_file(
      :cluster_1,
      HelloWorld.Workflow,
      "src/replay_test/replay_test_workflow.json"
    )
  end

  def replay_from_json() do
    {%{workflow_execution: we}, _} =
      TemporalSdk.start_workflow(:cluster_1, "default", ReplayTest.Workflow, [
        :wait,
        input: [["from Temporal"]]
      ])

    {:ok, _history, json} = TemporalSdk.get_workflow_history(:cluster_1, we, [:await_all, :json])
    TemporalSdk.replay_json(:cluster_1, ReplayTest.Workflow, json)
  end

  def create_json() do
    {%{workflow_execution: we}, _} =
      TemporalSdk.start_workflow(:cluster_1, "default", ReplayTest.Workflow, [:wait])

    TemporalSdk.get_workflow_history(:cluster_1, we, [:await_all, :history_file])
  end
end
