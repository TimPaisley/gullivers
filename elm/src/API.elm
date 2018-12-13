module API exposing (adventuresRequest, locationsRequest, logOutRequest, visitLocationRequest)

import Http
import Json.Decode as Decode exposing (Decoder, bool, float, int, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode
import List.Nonempty as Nonempty exposing (Nonempty)
import Types exposing (Adventure, AdventureCategory(..), LatLng, Location, Token)


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
    Decode.succeed Adventure
        |> required "id" int
        |> required "name" string
        |> required "image" string
        |> required "category" decodeCategory
        |> required "description" string
        |> required "locations" decodeLocations
        |> required "badge_url" string
        |> required "difficulty" int
        |> required "wheelchair_accessible" bool


decodeCategory : Decoder AdventureCategory
decodeCategory =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "path" ->
                        Decode.succeed Path

                    "collection" ->
                        Decode.succeed Collection

                    other ->
                        Decode.fail ("Unknown category: " ++ other)
            )


decodeLocations : Decoder (Nonempty Location)
decodeLocations =
    let
        decodeLocation =
            Decode.map4 makeLocation
                (Decode.field "id" Decode.int)
                (Decode.field "name" Decode.string)
                (Decode.field "description" Decode.string)
                (Decode.field "geometry" decodeGeometry)

        makeLocation id name description latLng =
            { id = id
            , name = name
            , description = description
            , latLng = latLng
            }

        decodeGeometry : Decoder LatLng
        decodeGeometry =
            Decode.string |> Decode.map (decodePointString >> pointPartsToLatLng) |> Decode.andThen (maybeToDecoder "Failed to decode geometry")

        pointPartsToLatLng : List String -> Maybe LatLng
        pointPartsToLatLng parts =
            case parts of
                _ :: lngString :: latString :: [] ->
                    Maybe.map2 (\lng lat -> { lng = lng, lat = lat })
                        (String.toFloat lngString)
                        (String.toFloat latString)

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


logOutRequest : Token -> Http.Request ()
logOutRequest token =
    Http.request
        { method = "DELETE"
        , headers =
            [ Http.header "X-CSRF-Token" token
            , Http.header "Accept" "application/json"
            ]
        , url = "/users/sign_out"
        , body = Http.emptyBody
        , expect = Http.expectJson <| Decode.succeed ()
        , timeout = Nothing
        , withCredentials = False
        }
