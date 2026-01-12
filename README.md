# Temporal Erlang and Elixir SDK samples

[![Hex Docs](https://img.shields.io/badge/hex-docs-informational?style=for-the-badge)](https://hexdocs.pm/temporal_sdk_samples)

This is the set of samples for the
[Temporal Erlang and Elixir SDK](https://github.com/andrzej-mag/temporal_sdk).

Each sample can be considered a standalone Elixir or Erlang application.
A list of samples with instructions on how to start and use each sample is provided in the
[hexdocs documentation](https://hexdocs.pm/temporal_sdk_samples/api-reference.html).

This software is published as a package on hex.pm to provide online hexdocs documentation exclusively.
Please refrain from adding this package to your Elixir or Erlang application dependencies as it
will have no effect.
Please refer to the [SDK repository](https://github.com/andrzej-mag/temporal_sdk) for instructions on
SDK usage.

## Usage

Clone this repository, fetch dependencies using `mix deps.get`, and start `iex -S mix` or `rebar3 shell`.
Run any of the [available samples](https://hexdocs.pm/temporal_sdk_samples/api-reference.html).
Saga pattern implementation example run:

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

The basic configuration files provided with this repository assume an unsecured Temporal server running
on `localhost:7233`.
For development and testing purposes it is recommended to run the
[Temporal CLI](https://github.com/temporalio/cli/) locally:

1. [Install](https://docs.temporal.io/cli#install) Temporal CLI.
2. [Start](https://docs.temporal.io/cli#start-dev-server) Temporal CLI dev server.
