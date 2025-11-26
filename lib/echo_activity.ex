defmodule EchoActivity do
  use TemporalSdk.Activity
  @moduledoc false

  @impl true
  def execute(%{task: %{attempt: attempt}}, [_echo, sleep_time, failed_attempts])
      when is_integer(sleep_time) and is_integer(failed_attempts) and attempt < failed_attempts do
    Process.sleep(sleep_time)
    throw("Test echo_activity throw")
  end

  def execute(_context, [echo, sleep_time, failed_attempts])
      when is_integer(sleep_time) and is_integer(failed_attempts) do
    Process.sleep(sleep_time)
    [do_echo(echo)]
  end

  def execute(_context, [echo, sleep_time]) when is_integer(sleep_time) do
    Process.sleep(sleep_time)
    [do_echo(echo)]
  end

  def execute(_context, [echo]), do: [do_echo(echo)]
  def execute(_context, echo), do: do_echo(echo)

  @impl true
  def handle_heartbeat(_context), do: :heartbeat

  @impl true
  def handle_cancel(%{cancel_requested: true}), do: {:cancel, ["cancel details"]}
  def handle_cancel(_context), do: :ignore

  @impl true
  def handle_message(_context, _message), do: :ignore

  @impl true
  def terminate(_context), do: :ok

  defp do_echo(echo) when is_binary(echo) and byte_size(echo) > 10_000, do: <<"large_payload">>
  defp do_echo(echo) when is_list(echo) and length(echo) > 3_300, do: <<"large_payload">>
  defp do_echo(echo), do: echo
end
