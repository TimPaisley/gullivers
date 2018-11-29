port module Ports exposing (updateMap)

import Json.Decode as Json exposing (Value)


type alias MapOptions =
    { elementID : String }


port updateMap : Maybe { lat : Float, lng : Float } -> Cmd msg
