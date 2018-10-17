module Main exposing (Location, Model, Msg(..), init, locationCard, main, update, view)

import Browser
import Html exposing (Html, div, h1, h2, img, p, text)
import Html.Attributes exposing (class, id, src)
import Http
import Json.Decode as Decode exposing (Decoder)
import RemoteData exposing (RemoteData(..), WebData)



---- MODEL ----


type alias Model =
    { flags : Flags
    , locations : WebData (List Location)
    }


type alias Flags =
    { csrfToken : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { flags = flags, locations = NotAsked }
    , locationsRequest flags.csrfToken
        |> RemoteData.sendRequest
        |> Cmd.map UpdateLocations
    )


type alias Location =
    { name : String
    , description : String
    , imageUrl : String
    , reward : Int
    , latLng : LatLng
    }


type alias LatLng =
    { lat : Float
    , lng : Float
    }



---- UPDATE ----


type Msg
    = NoOp
    | UpdateLocations (WebData (List Location))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateLocations locations ->
            ( { model | locations = locations }, Cmd.none )


locationsRequest : String -> Http.Request (List Location)
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


decodeLocations : Decoder (List Location)
decodeLocations =
    let
        decodeLocation =
            Decode.map5 makeLocation
                (Decode.field "name" Decode.string)
                (Decode.field "description" Decode.string)
                (Decode.field "image_url" Decode.string)
                (Decode.field "reward" Decode.int)
                (Decode.field "geometry" decodeGeometry)

        makeLocation name description imageUrl reward latLng =
            { name = name
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
    Decode.list decodeLocation


maybeToDecoder : String -> Maybe a -> Decoder a
maybeToDecoder error maybe =
    case maybe of
        Just a ->
            Decode.succeed a

        Nothing ->
            Decode.fail error



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ id "wrapper" ]
        [ h1 [] [ text "All Locations" ]
        , renderLocations model.locations
        ]


renderLocations : WebData (List Location) -> Html Msg
renderLocations remoteLocations =
    case remoteLocations of
        NotAsked ->
            text ""

        Loading ->
            text "Loading locations..."

        Success locations ->
            div [] (List.map locationCard locations)

        Failure _ ->
            text "Error"


locationCard : Location -> Html Msg
locationCard location =
    div [ class "card" ]
        [ img [ src location.imageUrl ] []
        , div [ class "content" ]
            [ h2 [] [ text location.name ]
            , p [] [ text location.description ]
            ]
        , div [ class "value" ] [ text <| String.fromInt location.reward ]
        ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
