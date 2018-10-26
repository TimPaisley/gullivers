module Main exposing (Location, Model, Msg(..), init, locationCard, main, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, div, h1, h2, img, p, text)
import Html.Attributes exposing (class, href, id, src)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder)
import RemoteData exposing (RemoteData(..), WebData)
import Url exposing (Url)



---- MODEL ----


type alias Model =
    { flags : Flags
    , locations : WebData (List Location)
    , screen : Screen
    , key : Nav.Key
    }


type alias Flags =
    { csrfToken : String }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { flags = flags, locations = NotAsked, screen = screenFromUrl url, key = key }
    , locationsRequest flags.csrfToken
        |> RemoteData.sendRequest
        |> Cmd.map UpdateLocations
    )


type Screen
    = Home
    | Locations


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
    | ChangeScreen Screen
    | RequestUrl Browser.UrlRequest
    | ChangeUrl Url


screenFromUrl : Url -> Screen
screenFromUrl url =
    case url.path of
        "/" ->
            Home

        "/locations" ->
            Locations

        _ ->
            Home


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateLocations locations ->
            ( { model | locations = locations }, Cmd.none )

        ChangeScreen screen ->
            ( { model | screen = screen }, Cmd.none )

        RequestUrl urlRequest ->
            let
                _ =
                    Debug.log "Request URL" urlRequest
            in
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ChangeUrl url ->
            let
                _ =
                    Debug.log "Change URL" url
            in
            ( { model | screen = screenFromUrl url }, Cmd.none )


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


document : Model -> Browser.Document Msg
document model =
    { title = "Gulliver's Guide"
    , body = [ view model ]
    }


view : Model -> Html Msg
view model =
    div [ id "wrapper" ]
        [ case model.screen of
            Home ->
                renderHomeScreen model

            Locations ->
                renderLocationsScreen model
        ]


renderHomeScreen : Model -> Html Msg
renderHomeScreen model =
    div []
        [ h1 [] [ text "Home" ]
        , a [ href "/locations" ] [ text "Locations" ]
        ]


renderLocationsScreen : Model -> Html Msg
renderLocationsScreen model =
    div []
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
    Browser.application
        { view = document
        , init = init
        , update = update
        , subscriptions = always Sub.none
        , onUrlRequest = RequestUrl
        , onUrlChange = ChangeUrl
        }
