-module(temporal_sdk_samples_sup).
-behaviour(supervisor).

% elp:ignore W0012 W0040
-moduledoc false.

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    SupFlags = #{strategy => one_for_all, intensity => 0, period => 1},
    ChildSpecs = [],
    {ok, {SupFlags, ChildSpecs}}.
