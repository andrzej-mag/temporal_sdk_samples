Demonstrates practical usage of the workflow replay functions.

This sample provides several functions illustrating workflow replay functionality:

- `replay_from_file/0` - replays a workflow execution using a recorded event history stored in a JSON
  file,
- `replay_from_file_nde/0` - same as above, but uses a mismatched workflow implementation, which
  results in a nondeterministic replay error,
- `replay_from_json/0` - executes a workflow, retrieves its history, and replays the execution using the
  retrieved history,
- `create_json/0` - executes a workflow, retrieves its history, and saves it to a JSON file in the current
  working directory; the filename defaults to the workflow’s `run_id`.

Example run:

<!-- tabs-open -->
### Elixir

```elixir
iex(1)> ReplayTest.replay_from_file()
{:ok, {:completed, []}}
iex(2)> ReplayTest.replay_from_file_nde()
{:error, {:nondeterministic,
...
iex(3)> ReplayTest.replay_from_json()
{:ok, {:completed, []}}
iex(4)> ReplayTest.create_json()
{:ok, [%{attributes: {:workflow_execution_started_event_attributes,
...
```

Sample source:
[lib/replay_test](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/lib/replay_test)

### Erlang

```erlang
1> replay_test:replay_from_file().
{ok,{completed,[]}}
2> replay_test:replay_from_file_nde().
{error, {nondeterministic,
...
3> replay_test:replay_from_json().
{ok,{completed,[]}}
4> replay_test:create_json().
{ok,[#{attributes => {workflow_execution_started_event_attributes,
...
```

Sample source:
[src/replay_test](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/src/replay_test)

<!-- tabs-close -->
