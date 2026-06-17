defmodule OtelSample.Activity do
  use TemporalSdk.Activity
  @moduledoc false
  require OpenTelemetry.Tracer, as: Tracer

  @impl true
  def execute(_context, _input) do
    baggage = :otel_baggage.get_all()
    baggage_attr = Enum.map(baggage, fn {k, {v, _meta}} -> {k, v} end)
    Tracer.set_attributes(baggage_attr)

    Tracer.with_span "my_activity_span", %{:attributes => baggage_attr} do
      Process.sleep(20)
    end

    ["ok"]
  end
end
