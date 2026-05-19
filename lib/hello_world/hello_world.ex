defmodule HelloWorld do
  @external_resource "docs/hello_world.md"
  @moduledoc TemporalSdk.Utils.Code.exdoc!("docs/hello_world.md")

  def start do
    TemporalSdk.start_workflow(:cluster_1, "default", HelloWorld.Workflow, [
      :wait,
      input: [["from Temporal"]]
    ])
  end
end
