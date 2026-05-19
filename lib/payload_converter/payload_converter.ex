defmodule PayloadConverter do
  @external_resource "docs/payload_converter.md"
  @moduledoc TemporalSdk.Utils.Code.exdoc!("docs/payload_converter.md")

  def start_default do
    TemporalSdk.start_workflow(:cluster_1, "default", HelloWorld.Workflow, [
      :wait,
      input: [["from Temporal"]],
      workflow_id: "plain"
    ])
  end

  def start_encrypted do
    TemporalSdk.start_workflow(:cluster_1_enc, "encrypted", HelloWorld.Workflow, [
      :wait,
      input: [["from Temporal"]],
      workflow_id: "encrypted"
    ])
  end
end
