# Temporal Erlang SDK samples

[![Hex Version](https://img.shields.io/hexpm/v/temporal_sdk_samples?style=for-the-badge)](https://hex.pm/packages/temporal_sdk_samples)
[![Hex Docs](https://img.shields.io/badge/hex-docs-informational?style=for-the-badge)](https://hexdocs.pm/temporal_sdk_samples)

This is the set of samples for the
[Temporal Erlang SDK](https://github.com/andrzej-mag/temporal_sdk).

## Usage

Clone this repository and start `rebar3 shell`.
Run any of the [available samples](https://hexdocs.pm/temporal_sdk_samples/api-reference.html):

```erlang
1> saga:start().
Compensation activity started with:
    #{<<"deposit">> => <<"completed">>,<<"other">> => <<"failed">>,
      <<"withdraw">> => <<"canceled">>}
```

## Requirements

Temporal server running locally or available on `localhost:7233`.
The recommended option is to use [Temporal CLI](https://github.com/temporalio/cli/):

1. [Install](https://docs.temporal.io/cli#install) Temporal CLI.
2. [Start](https://docs.temporal.io/cli#start-dev-server) Temporal CLI dev server.
