defmodule MutableMarker do
  @external_resource "docs/mutable_marker.md"
  @moduledoc TemporalSdk.Utils.Code.exdoc!("docs/mutable_marker.md")

  def run do
    TemporalSdk.start_workflow(:cluster_1, "default", MutableMarker.Workflow,
      workflow_task_timeout: 1_000
    )

    :ok
  end
end
