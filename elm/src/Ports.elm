port module Ports exposing (MapOptions, getPosition, receivePosition, updateMap)

import Json.Decode as Json exposing (Value)
import Types exposing (LatLng)


type alias MapOptions =
    { elementID : String
    , focus : Maybe LatLng
    , locations : List LatLng
    }


port updateMap : Maybe MapOptions -> Cmd msg


port getPosition : () -> Cmd msg


port receivePosition : (LatLng -> msg) -> Sub msg
