defmodule OtelSample do
  @external_resource "docs/otel_sample.md"
  @moduledoc TemporalSdk.Utils.Code.exdoc!("docs/otel_sample.md")

  def run, do: TemporalSdk.start_workflow(:cluster_1, "default", OtelSample.Workflow)
end
