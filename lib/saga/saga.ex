defmodule Saga do
  @external_resource "docs/saga.md"
  @moduledoc TemporalSdk.Utils.exdoc!("docs/saga.md")

  def start(), do: TemporalSdk.start_workflow(:cluster_1, "default", Saga.Workflow, [:wait])
end
