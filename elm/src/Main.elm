module Main exposing (Model, Msg(..), init, main, update, view)

import API exposing (adventuresRequest, locationsRequest, logOutRequest, visitLocationRequest)
import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, h1, h2, h3, img, li, p, small, span, text, ul)
import Html.Attributes exposing (class, classList, href, id, src, style, target)
import Html.Events exposing (onClick)
import Icons exposing (backpackIcon, campfireIcon, compassIcon, mapIcon)
import List.Extra as ListX
import List.Nonempty as Nonempty exposing (Nonempty)
import Ports
import RemoteData exposing (RemoteData(..), WebData)
import Types exposing (Adventure, LatLng, Location, Screen(..), Token)
import Url exposing (Url)



---- MODEL ----


type alias Model =
    { flags : Flags
    , adventures : WebData (List Adventure)
    , screen : Screen
    , key : Nav.Key
    , visitResult : WebData ()
    }


type alias Flags =
    { token : Token }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( screen, cmd ) =
            screenFromUrl NotAsked url
    in
    ( { flags = flags
      , adventures = NotAsked
      , screen = screen
      , key = key
      , visitResult = NotAsked
      }
    , Cmd.batch
        [ API.adventuresRequest flags.token
            |> RemoteData.sendRequest
            |> Cmd.map UpdateAdventures
        , cmd
        ]
    )



---- UPDATE ----


type Msg
    = NoOp
    | UpdateAdventures (WebData (List Adventure))
    | ChangeScreen Screen
    | RequestUrl Browser.UrlRequest
    | ChangeUrl Url
    | VisitLocation Location
    | UpdateVisitResults (WebData ())
    | ViewAdventureMap Int
    | LogOut
    | RedirectHome (WebData ())


screenFromUrl : WebData (List Adventure) -> Url -> ( Screen, Cmd Msg )
screenFromUrl remoteAdventures url =
    let
        segments =
            String.split "/" url.path
                |> List.filter (\s -> s /= "")

        defaultLocation =
            { lat = -41, lng = 174 }
    in
    case segments of
        [] ->
            ( Home, Ports.updateMap Nothing )

        [ "adventures", stringId, "locations", stringIdx ] ->
            case ( String.toInt stringId, String.toInt stringIdx ) of
                ( Just id, Just idx ) ->
                    ( AdventureMap id idx
                    , (Ports.updateMap << Just) <|
                        Maybe.withDefault defaultLocation <|
                            locationLatLng remoteAdventures id idx
                    )

                _ ->
                    ( Home, Ports.updateMap Nothing )

        _ ->
            ( Home, Ports.updateMap Nothing )


locationLatLng : WebData (List Adventure) -> Int -> Int -> Maybe LatLng
locationLatLng remoteAdventures id idx =
    case remoteAdventures of
        Success adventures ->
            let
                maybeAdventure =
                    ListX.find (\a -> a.id == id) adventures

                maybeLocation =
                    -- Forgive me father, for I have sinned
                    Maybe.andThen (\a -> ListX.getAt (idx - 1) <| Nonempty.toList a.locations) maybeAdventure
            in
            Maybe.map .latLng maybeLocation

        _ ->
            Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateAdventures remoteAdventures ->
            let
                cmd =
                    case model.screen of
                        AdventureMap id idx ->
                            case locationLatLng remoteAdventures id idx of
                                Just latlng ->
                                    Ports.updateMap <| Just latlng

                                _ ->
                                    Cmd.none

                        _ ->
                            Cmd.none
            in
            ( { model | adventures = remoteAdventures }, cmd )

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

                ( screen, cmd ) =
                    screenFromUrl model.adventures url
            in
            ( { model | screen = screen }, cmd )

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
                    "/adventures/" ++ String.fromInt id ++ "/locations/1"
            in
            ( model, Cmd.batch [ Nav.pushUrl model.key url ] )

        LogOut ->
            ( model
            , logOutRequest model.flags.token
                |> RemoteData.sendRequest
                |> Cmd.map RedirectHome
            )

        RedirectHome _ ->
            ( { model | screen = Home }, Nav.load "/" )



---- VIEW ----


document : Model -> Browser.Document Msg
document model =
    { title = "Gulliver's Guide"
    , body = [ view model ]
    }


view : Model -> Html Msg
view model =
    div [ id "wrapper" ]
        [ case model.adventures of
            Success adventures ->
                case model.screen of
                    Home ->
                        renderHomeScreen adventures

                    AdventureMap id idx ->
                        renderAdventureMap model adventures id idx

            Failure _ ->
                text "Oops!"

            _ ->
                renderLoadingScreen
        ]


renderLoadingScreen : Html Msg
renderLoadingScreen =
    text "LOADING..."


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
        , div [ class "section", onClick LogOut ]
            [ h2 [] [ text "Development" ]
            , text "Junior Adventurer"
            ]
        ]


renderHomeScreen : List Adventure -> Html Msg
renderHomeScreen adventures =
    let
        header =
            div [ class "header" ]
                [ div [ class "title" ]
                    [ h1 [] [ text "Gulliver's Guide to Wellington" ]
                    , div [] [ text "All Adventures" ]
                    ]
                , renderProfile
                ]
    in
    div []
        [ header
        , renderAdventures adventures
        , renderFooter
        ]


renderAdventures : List Adventure -> Html Msg
renderAdventures adventures =
    ul [ class "cards" ] (List.indexedMap renderAdventureCard adventures)


renderAdventureCard : Int -> Adventure -> Html Msg
renderAdventureCard idx adventure =
    let
        wheelchairInfo =
            if adventure.wheelchair_accessible then
                "Wheelchair Accessible"

            else
                ""
    in
    li [ class "card-item" ]
        [ div [ class "card", onClick <| ViewAdventureMap adventure.id ]
            [ div [ class "image", style "background-image" ("url(" ++ adventure.image ++ ")") ] []
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


renderAdventureMap : Model -> List Adventure -> Int -> Int -> Html Msg
renderAdventureMap model adventures adventureId locationIdx =
    let
        maybeAdventure =
            ListX.find (\a -> a.id == adventureId) adventures
    in
    case maybeAdventure of
        Just adventure ->
            let
                header =
                    div [ class "header" ]
                        [ a [ href "/", class "back" ] [ text "◀" ]
                        , div [ class "title" ]
                            [ h1 [] [ text adventure.name ]
                            , text "Walkway"
                            ]
                        , div [ class "side" ]
                            [ text "?" ]
                        ]

                location =
                    ListX.getAt locationIdx (Nonempty.toList adventure.locations)
                        |> Maybe.withDefault (Nonempty.head adventure.locations)

                previousLocation =
                    if locationIdx > 1 then
                        a [ href <| "/adventures/" ++ String.fromInt adventureId ++ "/locations/" ++ (String.fromInt <| locationIdx - 1) ]
                            [ div [] [ text "Previous Location" ] ]

                    else
                        a [ class "disabled" ] [ div [] [ text "Previous Location" ] ]

                nextLocation =
                    if locationIdx < Nonempty.length adventure.locations then
                        a [ href <| "/adventures/" ++ String.fromInt adventureId ++ "/locations/" ++ (String.fromInt <| locationIdx + 1) ]
                            [ div [] [ text "Next Location" ] ]

                    else
                        a [ class "disabled" ] [ div [] [ text "Next Location" ] ]

                indicatorFor l =
                    div [ class "indicator", classList [ ( "active", l.id == locationIdx ) ] ] []
            in
            div [ id "adventure-map-screen" ]
                [ header
                , div [ id "map" ] []
                , div [ id "locations" ]
                    [ div [ class "content" ]
                        [ div [ class "indicators" ] (Nonempty.map indicatorFor adventure.locations |> Nonempty.toList)
                        , div [ class "title" ] [ text location.name ]
                        , p [ class "description" ] [ text location.description ]
                        , div [ class "buttons" ]
                            [ previousLocation
                            , nextLocation
                            ]
                        ]
                    ]
                ]

        Nothing ->
            text "Adventure 404"



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
