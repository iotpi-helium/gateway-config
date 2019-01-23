-module(gateway_gatt_char_wifi_services).
-include("gateway_gatt.hrl").

-behavior(gatt_characteristic).

-export([init/2, uuid/1, flags/1,
         read_value/1, limit_services/1]).

-record(state, { path :: ebus:object_path()
               }).

-define(MAX_VALUE_SIZE, 500).

uuid(_) ->
    ?UUID_GATEWAY_GATT_CHAR_WIFI_SERVICES.

flags(_) ->
    [read].

init(Path, _) ->
    Descriptors =
        [
         {gatt_descriptor_cud, 0, ["WiFi Services"]},
         {gatt_descriptor_pf, 1, [utf8_string]}
        ],
    {ok, Descriptors, #state{path=Path}}.

read_value(State=#state{}) ->
    Names = [Name || {Name, _} <- limit_services(gateway_config:wifi_services())],
    {ok, jsx:encode(Names), State}.

limit_services(Services) ->
    %% encode only the names and send back
    {_, Result} = lists:foldl(fun(S={Name, _}, {Size, Acc}) when length(Name) + 5 + Size =< ?MAX_VALUE_SIZE ->
                                      %% Add 5 for escaped string dlimiters and comma separator
                                      {Size + length(Name) + 5, [S | Acc]};
                                 (_, Acc) ->
                                      Acc
                              end,
                              %% Start with 5 for array delimiters and outer string encoding
                              {4, []},  Services),
    lists:reverse(Result).
