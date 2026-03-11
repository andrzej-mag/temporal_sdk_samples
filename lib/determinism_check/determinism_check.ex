defmodule DeterminismCheck do
  @behaviour :temporal_sdk_api_workflow_check
  @external_resource "docs/determinism_check.md"
  @moduledoc File.read!("docs/determinism_check.md")

  @spec replay(check_mod :: module(), input :: binary(), replay_input :: binary()) ::
          :temporal_sdk.replay_json_ret()
  def replay(check_mod, input, replay_input) do
    TemporalSdk.replay_task(
      :cluster_1,
      "default",
      DeterminismCheck.Workflow,
      DeterminismCheck.Workflow,
      start_workflow_opts: [input: [[input]]],
      replay_workflow_opts: [
        worker_opts: [
          disable_telemetry: true,
          task_settings: [deterministic_check_mod: check_mod]
        ],
        task_overwrites: [input: [[replay_input]]]
      ]
    )
  end

  # -------------------------------------------------------------------------------------------------
  # behaviour implementation

  @doc false
  def is_deterministic(
        {actual_awaitable, %{event_id: event_id, state: actual_state}},
        {received_awaitable, %{event_id: event_id, state: received_state}},
        _actual_command,
        _received_history_event
      ),
      do:
        test_state(actual_state, received_state) and
          test_awaitable(actual_awaitable, received_awaitable)

  def is_deterministic(
        _actual_awaitable,
        _received_awaitable,
        _actual_command,
        _received_history_event
      ),
      do: false

  defp test_state(:cmd, _state), do: true
  defp test_state(:started, :canceled), do: true
  defp test_state(state, state), do: true
  defp test_state(_actual_state, _received_state), do: false

  defp test_awaitable({a}, {a}), do: true
  defp test_awaitable({a, _}, {a, _}), do: true
  defp test_awaitable({a, at, _}, {a, at, _}), do: true
  defp test_awaitable(_actual_awaitable, _received_awaitable), do: false
end
