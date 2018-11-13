module Main exposing (Location, Model, Msg(..), init, locationCard, main, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, h1, h2, h3, img, li, p, span, text, ul)
import Html.Attributes exposing (class, href, id, src, style)
import Html.Events exposing (onClick)
import Http
import Icons exposing (backpackIcon, campfireIcon, compassIcon, mapIcon)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import RemoteData exposing (RemoteData(..), WebData)
import Url exposing (Url)



---- MODEL ----


type alias Model =
    { flags : Flags
    , adventures : WebData (List Adventure)
    , locations : WebData (List Location)
    , screen : Screen
    , key : Nav.Key
    , visitResult : WebData ()
    }


type alias Flags =
    { token : Token }


type alias Token =
    String


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { flags = flags
      , adventures = NotAsked
      , locations = NotAsked
      , screen = screenFromUrl url
      , key = key
      , visitResult = NotAsked
      }
    , Cmd.batch
        [ locationsRequest flags.token
            |> RemoteData.sendRequest
            |> Cmd.map UpdateLocations
        , adventuresRequest flags.token
            |> RemoteData.sendRequest
            |> Cmd.map UpdateAdventures
        ]
    )


type Screen
    = Home
    | Adventures
    | AdventureMap Int
    | Locations


type alias Adventure =
    { id : Int
    , name : String
    , description : String
    , badgeUrl : String
    , difficulty : Int
    , wheelchair_accessible : Bool
    }


type alias Location =
    { id : Int
    , name : String
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
    | UpdateAdventures (WebData (List Adventure))
    | UpdateLocations (WebData (List Location))
    | ChangeScreen Screen
    | RequestUrl Browser.UrlRequest
    | ChangeUrl Url
    | VisitLocation Location
    | UpdateVisitResults (WebData ())
    | ViewAdventureMap Int


screenFromUrl : Url -> Screen
screenFromUrl url =
    let
        segments =
            String.split "/" url.path
                |> List.filter (\s -> s /= "")
    in
    case segments of
        [] ->
            Home

        [ "adventures" ] ->
            Adventures

        [ "adventures", stringId ] ->
            case String.toInt stringId of
                Just id ->
                    AdventureMap id

                Nothing ->
                    Adventures

        [ "locations" ] ->
            Locations

        _ ->
            Home


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateAdventures adventures ->
            ( { model | adventures = adventures }, Cmd.none )

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

        VisitLocation location ->
            ( model
            , visitLocationRequest model.flags.token location
                |> RemoteData.sendRequest
                |> Cmd.map UpdateVisitResults
            )

        UpdateVisitResults result ->
            ( { model | visitResult = result }, Cmd.none )

        ViewAdventureMap id ->
            let
                url =
                    "/adventures/" ++ String.fromInt id
            in
            ( model, Nav.pushUrl model.key url )


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


locationsRequest : Token -> Http.Request (List Location)
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
    let
        decodeAdventure =
            Decode.map6 makeAdventure
                (Decode.field "id" Decode.int)
                (Decode.field "name" Decode.string)
                (Decode.field "description" Decode.string)
                (Decode.field "badge_url" Decode.string)
                (Decode.field "difficulty" Decode.int)
                (Decode.field "wheelchair_accessible" Decode.bool)

        makeAdventure id name description badgeUrl difficulty wheelchair_accessible =
            { id = id
            , name = name
            , description = description
            , badgeUrl = badgeUrl
            , difficulty = difficulty
            , wheelchair_accessible = wheelchair_accessible
            }
    in
    Decode.list decodeAdventure


decodeLocations : Decoder (List Location)
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
    Decode.list decodeLocation


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

            Adventures ->
                renderAdventuresScreen model

            AdventureMap id ->
                renderAdventureMap model id

            Locations ->
                renderLocationsScreen model
        ]


renderHeader : Screen -> Html Msg
renderHeader screen =
    let
        content =
            case screen of
                Home ->
                    [ a [ href "/" ] [ div [ class "back-button" ] [ text "← Log Out" ] ]
                    , h1 [] [ text "Gulliver's Guide" ]
                    ]

                Adventures ->
                    [ a [ href "/" ] [ div [ class "back-button" ] [ text "← Back to Home" ] ]
                    , h1 [] [ text "Adventures" ]
                    ]

                AdventureMap id ->
                    [ a [ href "/adventures" ] [ div [ class "back-button" ] [ text "← Back to Adventures" ] ]
                    , h1 [] [ text ("Adventure " ++ String.fromInt id) ]
                    ]

                Locations ->
                    [ a [ href "/" ] [ div [ class "back-button" ] [ text "← Back to Home" ] ]
                    , h1 [] [ text "Locations" ]
                    ]
    in
    div [ class "header" ] content


renderHomeScreen : Model -> Html Msg
renderHomeScreen model =
    div [ id "home-screen" ]
        [ renderHeader model.screen
        , renderProfile model
        , renderNews
        , a [ href "/adventures" ]
            [ div [ class "action-button" ]
                [ text "Go on an Adventure" ]
            ]
        ]


renderProfile : Model -> Html Msg
renderProfile model =
    div [ class "home-profile" ]
        [ div [ class "section left" ]
            [ img [ src "https://via.placeholder.com/100/333333/FFFFFF" ] []
            ]
        , div [ class "section right" ]
            [ span []
                [ text "Welcome back,"
                , h2 [] [ text "Development" ]
                ]
            , text "Level 1"
            ]
        ]


renderNews : Html Msg
renderNews =
    div [ class "home-news" ]
        [ div [ class "news-item" ]
            [ h3 [] [ text "Thanks for trying the Beta" ]
            , div [ class "date" ] [ text "05/11/18" ]
            , p [] [ text "Gulliver’s Guide is still in development, but with your help and support we’ll continue to work towards making it an even better experience." ]
            , p [] [ text "If you’ve got any feedback, please feel free to contact us — we’d be more than happy to hear your thoughts!" ]
            ]
        , div [ class "news-item" ]
            [ h3 [] [ text "Gulliver's Diary - Entry 1" ]
            , div [ class "date" ] [ text "13/10/18" ]
            , p [] [ text "I've been thinking a lot lately -- perhaps I should create a guide to help everyone explore the hidden wonders in their city?" ]
            ]
        ]


renderAdventuresScreen : Model -> Html Msg
renderAdventuresScreen model =
    div [ id "adventures-screen" ]
        [ renderHeader model.screen
        , renderAdventures model.adventures
        ]


renderAdventures : WebData (List Adventure) -> Html Msg
renderAdventures remoteAdventures =
    case remoteAdventures of
        NotAsked ->
            text ""

        Loading ->
            text "Loading Adventures..."

        Success adventures ->
            ul [ class "cards" ] (List.indexedMap renderAdventureCard adventures)

        Failure _ ->
            text "error"


renderAdventureCard : Int -> Adventure -> Html Msg
renderAdventureCard idx adventure =
    let
        imageUrl =
            "https://unsplash.it/800/600?image=" ++ String.fromInt (70 + idx)

        wheelchairInfo =
            if adventure.wheelchair_accessible then
                "Wheelchair Accessible"

            else
                ""
    in
    li [ class "card-item" ]
        [ div [ class "card", onClick <| ViewAdventureMap adventure.id ]
            [ div [ class "image", style "background-image" ("url(" ++ imageUrl ++ ")") ] []
            , div [ class "content" ]
                [ div [ class "title" ] [ text adventure.name ]
                , p [ class "description" ] [ text adventure.description ]
                , div [ class "information" ]
                    [ div [] [ text wheelchairInfo ]
                    , div [] [ text <| "Difficulty Level " ++ String.fromInt adventure.difficulty ]
                    ]
                ]
            ]
        ]


renderAdventureMap : Model -> Int -> Html Msg
renderAdventureMap model adventureId =
    div [ id "adventure-map-screen" ]
        [ renderHeader model.screen
        , div [ class "embed-container" ] []
        ]


renderLocationsScreen : Model -> Html Msg
renderLocationsScreen model =
    div []
        [ renderHeader model.screen
        , renderVisitStatus model.visitResult
        , a [ href "/" ] [ text "Home" ]
        , renderLocations model.locations
        ]


renderVisitStatus : WebData () -> Html Msg
renderVisitStatus result =
    div [] [ text <| Debug.toString result ]


renderLocations : WebData (List Location) -> Html Msg
renderLocations remoteLocations =
    case remoteLocations of
        NotAsked ->
            text ""

        Loading ->
            text "Loading Locations..."

        Success locations ->
            div [] (List.map locationCard locations)

        Failure _ ->
            text "Error"


locationCard : Location -> Html Msg
locationCard location =
    div [ class "card", onClick (VisitLocation location) ]
        [ img [ src location.imageUrl ] []
        , div [ class "content" ]
            [ h2 [] [ text location.name ]
            , p [] [ text "Undiscovered" ]
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
