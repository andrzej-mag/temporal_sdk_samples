-module(temporal_sdk_samples_app).
-behaviour(application).

% elp:ignore W0012 W0040
-moduledoc false.

-export([start/2, stop/1]).

start(_StartType, _StartArgs) -> temporal_sdk_samples_sup:start_link().

stop(_State) -> ok.
