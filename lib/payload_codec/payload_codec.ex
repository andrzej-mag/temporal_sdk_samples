defmodule PayloadCodec do
  @external_resource "docs/payload_codec.md"
  @moduledoc File.read!("docs/payload_codec.md")

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
