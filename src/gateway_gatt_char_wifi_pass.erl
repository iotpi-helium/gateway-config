-module(gateway_gatt_char_wifi_pass).
-include("gateway_gatt.hrl").

-behavior(gatt_characteristic).

-export([init/2, uuid/1, flags/1,
         write_value/2]).

-record(state, { path :: ebus:object_path(),
                 value :: binary()
               }).


uuid(_) ->
    ?UUID_GATEWAY_GATT_CHAR_WIFI_PASS.

flags(_) ->
    [write].

init(Path, _) ->
    Descriptors =
        [
         {gatt_descriptor_cud, 0, ["WiFi Password"]}
        ],
    {ok, Descriptors,
     #state{path=Path, value= <<>>}}.


write_value(State=#state{}, Bin) ->
    lager:info("Changed WiFi password"),
    self() ! {changed_wifi_pass, Bin},
    {ok, State#state{value=Bin}}.
