defmodule OtelSample.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @impl true
  def execute(_context, _input) do
    %{value: uuid} = record_uuid4([:wait])

    case is_binary(uuid) do
      true -> otel_set_baggage("uuid", uuid, [{"meta_key", "meta_val"}])
      false -> otel_set_baggage("uuid", "invalid", [])
    end

    otel_set_attributes(%{attr_key: :attr_value})
    start_activity(OtelSample.Activity, [], [:wait])
    otel_add_event(:workflow_event, %{event_key: :event_val})
    start_child_workflow("default", OtelSampleChild.Workflow)
  end
end
