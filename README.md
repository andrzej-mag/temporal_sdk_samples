# Temporal Erlang/Elixir SDK samples

This is the set of samples for the
[unofficial Temporal Erlang/Elixir SDK](https://github.com/andrzej-mag/temporal_sdk).

A list of samples with instructions on how to start and use each sample is provided in the
[documentation](https://github.com/andrzej-mag/temporal_sdk_samples/tree/main/docs).

## Usage

Clone this repository, fetch dependencies using `mix deps.get`, and start `iex -S mix` or `rebar3 shell`.
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
3. Open your web browser at <http://localhost:8233> to inspect executed workflow samples.

## Documentation

ExDoc documentation can be generated using `mix docs`, and the resulting files are placed in the
`_doc` directory.
