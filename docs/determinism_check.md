Example implementation of the `m:temporal_sdk_api_workflow_check` workflow determinism check
behaviour module.

Erlang and Elixir SDK provide two built-in implementations of the `m:temporal_sdk_api_workflow_check`
behaviour: `temporal_sdk_api_workflow_check_strict` and `temporal_sdk_api_workflow_check_temporal`.

The workflow determinism check behaviour implementation in this sample `determinism_check` is aligned
with `temporal_sdk_api_workflow_check_temporal`, but with stricter rules: while the official implementation
considers awaitables deterministic if their *kind* matches, this sample requires both *kind* and *type*
to match.

Sample uses a workflow implementation that branches based on the workflow input. If the input is set to
`~"uuid4"`, the workflow records a UUID4 marker; if set to `~"echo_activity"`, it executes the
`echo_activity` activity, and so on.

Example run:

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> DeterminismCheck.replay(DeterminismCheck, "uuid4", "uuid4")
{:ok, {:completed, []}}
iex(2)> DeterminismCheck.replay(DeterminismCheck, "uuid4", "rand_uniform")
{:error, {:nondeterministic,
...
iex(3)> DeterminismCheck.replay(DeterminismCheck, "echo_activity", "hello_activity")
{:ok, {:completed, []}}
iex(4)> DeterminismCheck.replay(DeterminismCheck, "echo_activity", "uuid4")
{:error, {:nondeterministic,
...

iex(5)> DeterminismCheck.replay(:temporal_sdk_api_workflow_check_strict, "uuid4", "uuid4")
{:ok, {:completed, []}}
iex(6)> DeterminismCheck.replay(:temporal_sdk_api_workflow_check_strict, "uuid4", "rand_uniform")
{:error, {:nondeterministic,
...
iex(7)> DeterminismCheck.replay(:temporal_sdk_api_workflow_check_strict, "echo_activity", "hello_activity")
{:error, {:nondeterministic,
...
iex(8)> DeterminismCheck.replay(:temporal_sdk_api_workflow_check_strict, "echo_activity", "uuid4")
{:error, {:nondeterministic,
...

iex(9)> DeterminismCheck.replay(:temporal_sdk_api_workflow_check_temporal, "uuid4", "uuid4")
{:ok, {:completed, []}}
iex(10)> DeterminismCheck.replay(:temporal_sdk_api_workflow_check_temporal, "uuid4", "rand_uniform")
{:ok, {:completed, []}}
iex(11)> DeterminismCheck.replay(:temporal_sdk_api_workflow_check_temporal, "echo_activity", "hello_activity")
{:ok, {:completed, []}}
iex(12)> DeterminismCheck.replay(:temporal_sdk_api_workflow_check_temporal, "echo_activity", "uuid4")
{:error, {:nondeterministic,
...
```

Sample source:
[lib/determinism_check](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/determinism_check)

### Erlang

```erlang
1> determinism_check:replay(determinism_check, ~"uuid4", ~"uuid4").
{ok,{completed,[]}}
2> determinism_check:replay(determinism_check, ~"uuid4", ~"rand_uniform").
{error,{nondeterministic,
...
3> determinism_check:replay(determinism_check, ~"echo_activity", ~"hello_activity").
{ok,{completed,[]}}
4> determinism_check:replay(determinism_check, ~"echo_activity", ~"uuid4").
{error,{nondeterministic,
...

5> determinism_check:replay(temporal_sdk_api_workflow_check_strict, ~"uuid4", ~"uuid4").
{ok,{completed,[]}}
6> determinism_check:replay(temporal_sdk_api_workflow_check_strict, ~"uuid4", ~"rand_uniform").
{error,{nondeterministic,
...
7> determinism_check:replay(temporal_sdk_api_workflow_check_strict, ~"echo_activity", ~"hello_activity").
{error,{nondeterministic,
...
8> determinism_check:replay(temporal_sdk_api_workflow_check_strict, ~"echo_activity", ~"uuid4").
{error,{nondeterministic,
...

9> determinism_check:replay(temporal_sdk_api_workflow_check_temporal, ~"uuid4", ~"uuid4").
{ok,{completed,[]}}
10> determinism_check:replay(temporal_sdk_api_workflow_check_temporal, ~"uuid4", ~"rand_uniform").
{ok,{completed,[]}}
11> determinism_check:replay(temporal_sdk_api_workflow_check_temporal, ~"echo_activity", ~"hello_activity").
{ok,{completed,[]}}
12> determinism_check:replay(temporal_sdk_api_workflow_check_temporal, ~"echo_activity", ~"uuid4").
{error,{nondeterministic,
...
```

Sample source:
[src/determinism_check](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/determinism_check)

<!-- tabs-close -->
