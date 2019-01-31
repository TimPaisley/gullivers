port module Ports exposing (MapOptions, enableGeolocation, geoDecoder, receiveGeoData, updateMap)

import Json.Decode as Decode exposing (Decoder, Value)
import Types exposing (GeoData(..), LatLng)


type alias MapOptions =
    { elementID : String
    , focus : Maybe LatLng
    , position : Maybe LatLng
    , locations : List LatLng
    }


port updateMap : Maybe MapOptions -> Cmd msg


port enableGeolocation : () -> Cmd msg


port receiveGeoData : (Value -> msg) -> Sub msg


geoDecoder : Decoder GeoData
geoDecoder =
    Decode.oneOf [ geoSuccessDecoder, geoErrorDecoder ]


latLngDecoder : Decoder LatLng
latLngDecoder =
    Decode.map2 LatLng
        (Decode.at [ "coords", "latitude" ] Decode.float)
        (Decode.at [ "coords", "longitude" ] Decode.float)


geoSuccessDecoder : Decoder GeoData
geoSuccessDecoder =
    Decode.map Success latLngDecoder


geoErrorDecoder : Decoder GeoData
geoErrorDecoder =
    Decode.map Failure Decode.string
