defmodule MutableMarker.Workflow do
  use TemporalSdk.Workflow
  @moduledoc false

  @mutable_marker ~c"mutable_marker"

  @impl true
  def execute(_context, _input) do
    # Don't run side effects inside workflow implementation
    mock_env()

    %{result: [a1r]} = start_activity(EchoActivity, [["first_activity"]], [:wait])

    %{mutations_count: mc, value: [mv]} =
      record_os_env(@mutable_marker, [:wait, mutable: %{mutations_limit: 5}])

    IO.puts("Mutable Marker - mutations count: #{mc}, marker value: #{mv}.")
    a2 = start_activity(EchoActivity, [["second_activity", mv], 3_000])

    # Following code emulates 3 worker node restarts during workflow execution
    start_timer(1000, [:wait])

    case mc < 3 do
      true ->
        terminate_executor()

      false ->
        %{result: [a2r]} = wait(a2)
        complete_workflow_execution([a1r, a2r])
    end
  end

  defp mock_env() do
    val =
      [:positive, :monotonic]
      |> :erlang.unique_integer()
      |> Integer.to_charlist()

    :os.putenv(@mutable_marker, val)
  end
end
