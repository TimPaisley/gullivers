module API exposing (adventuresRequest, locationsRequest, visitLocationRequest)

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import List.Nonempty as Nonempty exposing (Nonempty)
import Types exposing (Adventure, LatLng, Location, Token)


adventuresRequest : Token -> Http.Request (List Adventure)
adventuresRequest token =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "X-CSRF-Token" token
            , Http.header "Accept" "application/json"
            ]
        , url = "/adventures"
        , body = Http.emptyBody
        , expect = Http.expectJson decodeAdventures
        , timeout = Nothing
        , withCredentials = False
        }


locationsRequest : Token -> Http.Request (Nonempty Location)
locationsRequest token =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "X-CSRF-Token" token
            , Http.header "Accept" "application/json"
            ]
        , url = "/locations"
        , body = Http.emptyBody
        , expect = Http.expectJson decodeLocations
        , timeout = Nothing
        , withCredentials = False
        }


decodeAdventures : Decoder (List Adventure)
decodeAdventures =
    Decode.list decodeAdventure


decodeAdventure : Decoder Adventure
decodeAdventure =
    let
        makeAdventure id name description locations badgeUrl difficulty wheelchair_accessible =
            { id = id
            , name = name
            , description = description
            , locations = locations
            , badgeUrl = badgeUrl
            , difficulty = difficulty
            , wheelchair_accessible = wheelchair_accessible
            }
    in
    Decode.map7 makeAdventure
        (Decode.field "id" Decode.int)
        (Decode.field "name" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "locations" decodeLocations)
        (Decode.field "badge_url" Decode.string)
        (Decode.field "difficulty" Decode.int)
        (Decode.field "wheelchair_accessible" Decode.bool)


decodeLocations : Decoder (Nonempty Location)
decodeLocations =
    let
        decodeLocation =
            Decode.map6 makeLocation
                (Decode.field "id" Decode.int)
                (Decode.field "name" Decode.string)
                (Decode.field "description" Decode.string)
                (Decode.field "image_url" Decode.string)
                (Decode.field "reward" Decode.int)
                (Decode.field "geometry" decodeGeometry)

        makeLocation id name description imageUrl reward latLng =
            { id = id
            , name = name
            , description = description
            , imageUrl = imageUrl
            , reward = reward
            , latLng = latLng
            }

        decodeGeometry : Decoder LatLng
        decodeGeometry =
            Decode.string |> Decode.map (decodePointString >> pointPartsToLatLng) |> Decode.andThen (maybeToDecoder "Failed to decode geometry")

        pointPartsToLatLng : List String -> Maybe LatLng
        pointPartsToLatLng parts =
            case parts of
                _ :: latString :: lngString :: [] ->
                    Maybe.map2 (\lat lng -> { lat = lat, lng = lng })
                        (String.toFloat latString)
                        (String.toFloat lngString)

                _ ->
                    Nothing

        decodePointString : String -> List String
        decodePointString s =
            s
                |> String.replace "(" ""
                |> String.replace ")" ""
                |> String.split " "
    in
    decodeNonempty decodeLocation


decodeNonempty : Decoder a -> Decoder (Nonempty a)
decodeNonempty decoder =
    Decode.list decoder
        |> Decode.map Nonempty.fromList
        |> Decode.andThen (maybeToDecoder "List was unexpectedly empty")


maybeToDecoder : String -> Maybe a -> Decoder a
maybeToDecoder error maybe =
    case maybe of
        Just a ->
            Decode.succeed a

        Nothing ->
            Decode.fail error


visitLocationRequest : Token -> Location -> Http.Request ()
visitLocationRequest token location =
    Http.request
        { method = "POST"
        , headers =
            [ Http.header "X-CSRF-Token" token
            , Http.header "Accept" "application/json"
            ]
        , url = "/visits"
        , body = Http.jsonBody <| encodeLocation location
        , expect = Http.expectJson <| Decode.succeed ()
        , timeout = Nothing
        , withCredentials = False
        }


encodeLocation : Location -> Encode.Value
encodeLocation location =
    Encode.object [ ( "location_id", Encode.int location.id ) ]
