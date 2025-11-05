-module(echo_activity).

% elp:ignore W0012 W0040
-moduledoc """
"echo" activity used across samples.

Activity can be started with a following input variants:
* `[Echo]` - where `Echo` is any Erlang term that can be converted with current payload codec.
  `Echo` value is returned as activity result,
* `[Echo, SleepTime]` - activity will run `timer:sleep(SleepTime)` command pretendig of doing some
  work,
* `[Echo, SleepTime, FailedAttempts]` - activity execution will fail with
  `throw("Test echo_activity failure")` for `FailedAttempts` count.

If `byte_size(Echo) > 10_000` or `length(Echo) > 3_300` activity returns `~"large_payload"`
as a result.

Example:
```erlang
start_activity(echo_activity, ["echo", 10_000, 3])
```

""".

-export([
    execute/2,
    terminate/1,
    handle_heartbeat/1,
    handle_cancel/1,
    handle_message/2
]).

-include_lib("temporal_sdk/include/activity.hrl").

-doc false.
execute(#{task := #{attempt := Attempt}}, [_Echo, SleepTime, FailedAttempts]) when
    is_integer(SleepTime), is_integer(FailedAttempts), Attempt < FailedAttempts
->
    timer:sleep(SleepTime),
    throw("Test echo_activity failure");
execute(_Context, [Echo, SleepTime, FailedAttempts]) when
    is_integer(SleepTime), is_integer(FailedAttempts)
->
    timer:sleep(SleepTime),
    [do_echo(Echo)];
execute(_Context, [Echo, SleepTime]) when is_integer(SleepTime) ->
    timer:sleep(SleepTime),
    [do_echo(Echo)];
execute(_Context, [Echo]) ->
    [do_echo(Echo)];
execute(_Context, Echo) ->
    do_echo(Echo).

do_echo(Echo) when is_binary(Echo), byte_size(Echo) > 10_000 -> ~"large_payload";
do_echo(Echo) when is_list(Echo), length(Echo) > 3_300 -> ~"large_payload";
do_echo(Echo) -> Echo.

-doc false.
handle_heartbeat(_Context) ->
    heartbeat.

-doc false.
handle_cancel(#{cancel_requested := true}) ->
    {cancel, ["cancel details"]};
handle_cancel(_Context) ->
    ignore.

-doc false.
handle_message(_Context, _Message) ->
    ignore.

-doc false.
terminate(_Context) ->
    ok.
