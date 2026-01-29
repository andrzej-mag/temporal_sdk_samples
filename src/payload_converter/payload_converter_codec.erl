-module(payload_converter_codec).
-behaviour(temporal_sdk_codec_payload).

-moduledoc false.

-export([
    convert/4
]).

-define(ENCODING, ~"binary/encrypted").

convert(
    #{data := Data, metadata := #{encoding := ?ENCODING}} = P, _Cluster, #{type := request}, Opts
) ->
    {ok, P#{data := encrypt(Data, Opts)}};
convert(
    #{data := Data, metadata := #{~"encoding" := ?ENCODING}} = P, _Cluster, #{type := request}, Opts
) ->
    {ok, P#{data := encrypt(Data, Opts)}};
convert(
    #{data := Data, metadata := #{"encoding" := ?ENCODING}} = P, _Cluster, #{type := request}, Opts
) ->
    {ok, P#{data := encrypt(Data, Opts)}};
convert(#{metadata := #{encoding := _}}, _Cluster, #{type := request}, _Opts) ->
    ignored;
convert(#{metadata := #{~"encoding" := _}}, _Cluster, #{type := request}, _Opts) ->
    ignored;
convert(#{metadata := #{"encoding" := _}}, _Cluster, #{type := request}, _Opts) ->
    ignored;
convert(#{data := Data} = Payload, _Cluster, #{type := request}, Opts) ->
    Encoded = encrypt(Data, Opts),
    M = maps:get(metadata, Payload, #{}),
    {ok, #{data => Encoded, metadata => M#{~"encoding" => ?ENCODING}}};
convert(
    #{data := Data, metadata := #{encoding := ?ENCODING}} = Payload,
    _Cluster,
    #{type := response},
    Opts
) ->
    {ok, Payload#{data := decrypt(Data, Opts)}};
convert(
    #{data := Data, metadata := #{~"encoding" := ?ENCODING}} = Payload,
    _Cluster,
    #{type := response},
    Opts
) ->
    {ok, Payload#{data := decrypt(Data, Opts)}};
convert(
    #{data := Data, metadata := #{"encoding" := ?ENCODING}} = Payload,
    _Cluster,
    #{type := response},
    Opts
) ->
    {ok, Payload#{data := decrypt(Data, Opts)}};
convert(_Payload, _Cluster, _RequestInfo, _Opts) ->
    ignored.

%% As this is just an example, we store encryption secrets here.
%% Don't replicate such pattern in a real world application.

-define(KEY, <<1:128>>).
-define(IV, <<0:128>>).

encrypt(Data, Opts) ->
    Bin = erlang:term_to_binary(Data, Opts),
    Enc = crypto:crypto_one_time(aes_128_ctr, ?KEY, ?IV, Bin, true),
    base64:encode(Enc).

decrypt(Data, Opts) ->
    Dec = base64:decode(Data),
    Bin = crypto:crypto_one_time(aes_128_ctr, ?KEY, ?IV, Dec, false),
    erlang:binary_to_term(Bin, Opts).
