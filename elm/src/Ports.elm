port module Ports exposing (MapOptions, updateMap)

import Json.Decode as Json exposing (Value)
import Types exposing (LatLng)


type alias MapOptions =
    { elementID : String
    , focus : Maybe LatLng
    , locations : List LatLng
    }


port updateMap : Maybe MapOptions -> Cmd msg
