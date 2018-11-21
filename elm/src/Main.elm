module Main exposing (Model, Msg(..), init, main, update, view)

import API exposing (adventuresRequest, currentAdventureRequest, locationsRequest, visitLocationRequest)
import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, h1, h2, h3, img, li, p, span, text, ul)
import Html.Attributes exposing (class, href, id, src, style, target)
import Html.Events exposing (onClick)
import Icons exposing (backpackIcon, campfireIcon, compassIcon, mapIcon)
import RemoteData exposing (RemoteData(..), WebData)
import Types exposing (Adventure, Location, Screen(..), Token)
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
        [ API.locationsRequest flags.token
            |> RemoteData.sendRequest
            |> Cmd.map UpdateLocations
        , API.adventuresRequest flags.token
            |> RemoteData.sendRequest
            |> Cmd.map UpdateAdventures
        ]
    )



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

        [ "adventures", stringId ] ->
            case String.toInt stringId of
                Just id ->
                    AdventureMap id

                Nothing ->
                    Home

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

            AdventureMap id ->
                renderAdventureMap model id
        ]


renderHeader : Screen -> Html Msg
renderHeader screen =
    let
        content =
            case screen of
                Home ->
                    [ div []
                        [ div [] [ text "Gulliver's Guide to Wellington" ]
                        , h1 [] [ text "Adventures" ]
                        ]
                    , renderProfile
                    ]

                AdventureMap id ->
                    [ div []
                        [ a [ href "/" ] [ text "← Back to Adventures" ]
                        , h1 [] [ text ("Adventure " ++ String.fromInt id) ]
                        ]
                    , div [ class "set-size" ]
                        [ div [ class "pie-wrapper progress-80" ]
                            [ span [ class "label" ]
                                [ text "80"
                                , span [ class "smaller" ] [ text "%" ]
                                ]
                            , div [ class "pie" ]
                                [ div [ class "left-side half-circle" ] []
                                , div [ class "right-side half-circle" ] []
                                ]
                            ]
                        ]
                    ]
    in
    div [ class "header" ] content


renderFooter : Html Msg
renderFooter =
    div [ class "footer" ]
        [ a [ href "https://github.com/timpaisley/gullivers", target "_blank" ]
            [ div [] [ text "Made using Gulliver's Guide" ] ]
        , div [] [ text "About" ]
        , div [] [ text "Legal" ]
        , div [] [ text "Contact" ]
        ]


renderProfile : Html Msg
renderProfile =
    div [ class "profile" ]
        [ div [ class "section set-size" ]
            [ div [ class "pie-wrapper progress-80" ]
                [ span [ class "label" ]
                    [ text "8"
                    , span [ class "smaller" ] [ text "m" ]
                    ]
                , div [ class "pie" ]
                    [ div [ class "left-side half-circle" ] []
                    , div [ class "right-side half-circle" ] []
                    ]
                ]
            ]
        , div [ class "section" ]
            [ h2 [] [ text "Development" ]
            , text "Junior Adventurer"
            ]
        ]


renderHomeScreen : Model -> Html Msg
renderHomeScreen model =
    div []
        [ renderHeader model.screen
        , renderFilters
        , renderAdventures model.adventures
        , renderFooter
        ]


renderFilters : Html Msg
renderFilters =
    div [ class "filters" ]
        [ div [] [ text "Location" ]
        , div [] [ text "Difficulty" ]
        , div [] [ text "Accessibility" ]
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
        , div [ id "map" ] []
        , div [ id "locations" ]
            [ div [ class "content" ]
                [ div [ class "title" ] [ text "Location Name" ]
                , p [ class "description" ] [ text "Description" ]
                , div [ class "information" ]
                    [ div [] [ text "◀ Previous Location" ]
                    , div [] [ text "Next Location ▶" ]
                    ]
                ]
            ]
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
