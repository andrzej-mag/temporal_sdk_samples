# Temporal Erlang and Elixir SDK samples

[![Hex Docs](https://img.shields.io/badge/hex-docs-informational?style=for-the-badge)](https://hexdocs.pm/temporal_sdk_samples)

This is the set of samples for the
[Temporal Erlang and Elixir SDK](https://github.com/andrzej-mag/temporal_sdk).

## Usage

Clone this repository and start `iex -S mix` or `rebar3 shell`.
Run any of the [available samples](https://hexdocs.pm/temporal_sdk_samples/api-reference.html):

<!-- tabs-open -->

### Elixir

```elixir
iex(1)> Saga.start()
Compensation activity started with:
    %{"deposit" => "completed", "other" => "failed", "withdraw" => "canceled"}
...
```

### Erlang

```erlang
1> saga:start().
Compensation activity started with:
    #{<<"deposit">> => <<"completed">>,<<"other">> => <<"failed">>,
      <<"withdraw">> => <<"canceled">>}
...
```

<!-- tabs-close -->

## Requirements

Temporal server running locally or available on `localhost:7233`.
For development and testing purposes it is recommended to use
[Temporal CLI](https://github.com/temporalio/cli/):

1. [Install](https://docs.temporal.io/cli#install) Temporal CLI.
2. [Start](https://docs.temporal.io/cli#start-dev-server) Temporal CLI dev server.
