defmodule Saga do
  @moduledoc File.read!("docs/saga.md")

  def start(), do: :temporal_sdk.start_workflow(:cluster_1, "default", Saga.Workflow, [:wait])
end
