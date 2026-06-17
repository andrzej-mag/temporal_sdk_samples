defmodule OtelSampleChild.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @impl true
  def execute(context, _input) do
    %{workflow_info: %{opentelemetry_baggage: _baggage}} = context
    :ok
  end
end
