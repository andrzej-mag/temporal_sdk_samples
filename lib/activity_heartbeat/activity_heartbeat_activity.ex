defmodule ActivityHeartbeat.Activity do
  use TemporalSdk.Activity
  @moduledoc false

  # Work performed during each execution stage is simulated with `Process.sleep/1`.
  @impl true
  def execute(_context, _input) do
    # stage s1
    set_data(%{current_stage: :s1})
    Process.sleep(ActivityHeartbeat.stage_duration(1))
    # stage s2
    set_data(%{current_stage: :s2})
    Process.sleep(ActivityHeartbeat.stage_duration(2))
    # stage s3
    set_data(%{current_stage: :s3})
    Process.sleep(ActivityHeartbeat.stage_duration(3))
    ["activity completed"]
  end

  @impl true
  def handle_heartbeat(%{
        cancel_requested: cancel_requested,
        data: %{current_stage: stage},
        last_heartbeat: [%{current_stage: stage} = last_heartbeat]
      }) do
    %{^stage => heartbeat_count} = last_heartbeat
    nh = %{last_heartbeat | stage => heartbeat_count + 1, cancel_requested: cancel_requested}
    IO.puts("HB: #{inspect(nh)}")
    {:heartbeat, [nh]}
  end

  def handle_heartbeat(%{
        cancel_requested: cancel_requested,
        data: %{current_stage: stage},
        last_heartbeat: [%{} = last_heartbeat]
      }) do
    nh =
      Map.merge(last_heartbeat, %{
        stage => 1,
        current_stage: stage,
        cancel_requested: cancel_requested
      })

    IO.puts("HB: #{inspect(nh)}")
    {:heartbeat, [nh]}
  end

  def handle_heartbeat(%{
        cancel_requested: cancel_requested,
        data: %{current_stage: stage}
      }) do
    nh = %{:current_stage => stage, stage => 1, :cancel_requested => cancel_requested}
    IO.puts("HB: #{inspect(nh)}")
    {:heartbeat, [nh]}
  end

  @impl true
  def handle_cancel(%{cancel_requested: false}), do: :ignore

  def handle_cancel(%{data: %{current_stage: :s1}}) do
    IO.puts("cancelation: Cancelation in stage s1.")
    {:cancel, ["stage s1 cancelation"]}
  end

  def handle_cancel(%{data: %{current_stage: :s2}}) do
    IO.puts("cancelation: Ignore cancelation in stage s2.")
    :ignore
  end

  def handle_cancel(%{data: %{current_stage: :s3}}) do
    IO.puts("cancelation: Cleanup and cancelation in stage s3.")
    {:cancel, ["stage s3 cancelation"]}
  end
end
