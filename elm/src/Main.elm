module Main exposing (Model, Msg(..), init, main, update, view)

import API exposing (adventuresRequest, locationsRequest, logOutRequest, visitLocationRequest)
import Browser
import Browser.Navigation as Nav
import Color exposing (Color)
import Html exposing (Html, a, button, div, h1, h2, h3, img, li, p, small, span, text, ul)
import Html.Attributes exposing (class, classList, href, id, src, style, target)
import Html.Events exposing (onClick)
import List.Extra as ListX
import List.Nonempty as Nonempty exposing (Nonempty)
import Material.Icons.Action exposing (accessible, exit_to_app, feedback, home, subject)
import Material.Icons.Content exposing (filter_list, sort)
import Material.Icons.Navigation exposing (chevron_left, chevron_right)
import Material.Icons.Social exposing (share)
import Ports
import RemoteData exposing (RemoteData(..), WebData)
import Types exposing (Adventure, AdventureCategory(..), CardDisplay, Filter(..), LatLng, Location, Screen(..), Sort(..), Toggle(..), Token, allFilters, allSorts, filterToString, sortToString)
import Url exposing (Url)



---- MODEL ----


type alias Model =
    { flags : Flags
    , adventures : WebData (List Adventure)
    , screen : Screen
    , key : Nav.Key
    , visitResult : WebData ()
    , cardDisplay : CardDisplay
    , infoToggle : Bool
    }


type alias Flags =
    { token : Token }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( screen, cmd ) =
            screenFromUrl NotAsked url

        defaultCardDisplay =
            { toggle = Nothing
            , filter = All
            , sort = Name
            }
    in
    ( { flags = flags
      , adventures = NotAsked
      , screen = screen
      , key = key
      , visitResult = NotAsked
      , cardDisplay = defaultCardDisplay
      , infoToggle = False
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
    | ChangeToggle (Maybe Toggle)
    | ChangeFilter Filter
    | ChangeSort Sort
    | ToggleInfo


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
                    let
                        focus =
                            locationLatLng remoteAdventures id idx
                    in
                    ( AdventureMap id idx
                    , Ports.updateMap (mapOptions remoteAdventures id idx)
                    )

                _ ->
                    ( Home, Ports.updateMap Nothing )

        _ ->
            ( Home, Ports.updateMap Nothing )


mapOptions : WebData (List Adventure) -> Int -> Int -> Maybe Ports.MapOptions
mapOptions remoteAdventures id idx =
    case remoteAdventures of
        Success adventures ->
            case ListX.find (\a -> a.id == id) adventures of
                Just adventure ->
                    Just
                        { elementID = "map"
                        , focus = locationLatLng remoteAdventures id idx
                        , locations =
                            Nonempty.toList <|
                                Nonempty.map .latLng adventure.locations
                        }

                Nothing ->
                    Nothing

        _ ->
            Nothing


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
                                    Ports.updateMap (mapOptions remoteAdventures id idx)

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

        ChangeToggle newToggle ->
            let
                cardDisplay =
                    model.cardDisplay

                newCardDisplay =
                    { cardDisplay | toggle = newToggle }
            in
            ( { model | cardDisplay = newCardDisplay }, Cmd.none )

        ChangeFilter newFilter ->
            let
                cardDisplay =
                    model.cardDisplay

                newCardDisplay =
                    { cardDisplay | filter = newFilter }
            in
            ( { model | cardDisplay = newCardDisplay }, Cmd.none )

        ChangeSort newSort ->
            let
                cardDisplay =
                    model.cardDisplay

                newCardDisplay =
                    { cardDisplay | sort = newSort }
            in
            ( { model | cardDisplay = newCardDisplay }, Cmd.none )

        ToggleInfo ->
            ( { model | infoToggle = not model.infoToggle }, Cmd.none )



---- VIEW ----


document : Model -> Browser.Document Msg
document model =
    { title = "Gulliver's Guide"
    , body = [ view model ]
    }


view : Model -> Html Msg
view model =
    case model.adventures of
        Success adventures ->
            case model.screen of
                Home ->
                    div [ id "wrapper" ]
                        [ renderHomeScreen adventures model.cardDisplay ]

                AdventureMap id idx ->
                    renderAdventureMap model adventures id idx model.infoToggle

        Failure _ ->
            div [ id "wrapper" ] [ text "Oops!" ]

        _ ->
            renderLoadingScreen


renderLoadingScreen : Html Msg
renderLoadingScreen =
    text "LOADING..."


renderFooter : Html Msg
renderFooter =
    div [ class "footer" ]
        [ a [ href "https://github.com/timpaisley/gullivers", target "_blank" ]
            [ div [] [ text "Made using Gulliver's Guide" ] ]
        ]


renderProfile : Html Msg
renderProfile =
    div [ class "vertical-bar" ]
        [ div [ class "section" ]
            [ div [ class "explorer-icon" ] [] ]
        , div [ class "section main" ]
            [ div [ class "title" ] [ text "Development" ]
            , div [ class "subtitle" ] [ text "Junior Explorer" ]
            ]
        , div [ class "section icon", onClick LogOut ]
            [ exit_to_app Color.darkGrey 20, text "Log Out" ]
        ]


renderHomeScreen : List Adventure -> CardDisplay -> Html Msg
renderHomeScreen adventures display =
    let
        header =
            div [ class "header" ]
                [ div [ class "brand logo" ]
                    [ div [ class "title" ] [ text "Gulliver's Guide" ]
                    , div [ class "subtitle" ] [ text "to Wellington" ]
                    ]
                , renderProfile
                ]
    in
    div []
        [ header
        , renderAdventures adventures display
        , renderFooter
        ]


renderAdventures : List Adventure -> CardDisplay -> Html Msg
renderAdventures adventures display =
    let
        toggleAction toggle =
            if Just toggle == display.toggle then
                ChangeToggle Nothing

            else
                ChangeToggle (Just toggle)

        toggleBar =
            div [ class "vertical-bar" ]
                [ div [ class "section main" ]
                    [ div [ class "title" ] [ text "Adventures" ] ]
                , div [ class "section icon", onClick <| toggleAction Filter ]
                    [ filter_list Color.darkGrey 20, text "Filter" ]
                , div [ class "section icon", onClick <| toggleAction Sort ]
                    [ sort Color.darkGrey 20, text "Sort" ]
                ]

        action comparison msg selection =
            if selection == comparison then
                NoOp

            else
                msg selection

        toggles =
            case display.toggle of
                Just Filter ->
                    let
                        filterAction =
                            action display.filter ChangeFilter

                        section filter =
                            div
                                [ classList
                                    [ ( "section", True )
                                    , ( "selected", display.filter == filter )
                                    ]
                                , onClick <| filterAction filter
                                ]
                                [ text <| filterToString filter ]
                    in
                    div [ class "toggle-section" ] (List.map section allFilters)

                Just Sort ->
                    let
                        sortAction =
                            action display.sort ChangeSort

                        section sort =
                            div
                                [ classList
                                    [ ( "section", True )
                                    , ( "selected", display.sort == sort )
                                    ]
                                , onClick <| sortAction sort
                                ]
                                [ text <| sortToString sort ]
                    in
                    div [ class "toggle-section" ] (List.map section allSorts)

                Nothing ->
                    div [ class "toggle-section" ] []

        applyFilter =
            case display.filter of
                All ->
                    List.filter (\_ -> True)

                Accessible ->
                    List.filter .wheelchairAccessible

                Simple ->
                    List.filter (\a -> a.difficulty < 3)

        applySort =
            case display.sort of
                Name ->
                    List.sortBy .name

                Size ->
                    List.sortBy (\a -> Nonempty.length a.locations)

                Difficulty ->
                    List.sortBy .difficulty
    in
    div []
        [ toggleBar
        , toggles
        , adventures
            |> applyFilter
            |> applySort
            |> List.map renderAdventureCard
            |> ul [ class "cards" ]
        ]


renderAdventureCard : Adventure -> Html Msg
renderAdventureCard adventure =
    let
        wheelchairInfo =
            if adventure.wheelchairAccessible then
                accessible Color.darkGrey 20

            else
                text ""

        fill =
            toFloat adventure.difficulty / 5 * 100

        category =
            case adventure.category of
                Path ->
                    "Path"

                Collection ->
                    "Collection"

        difficulty =
            [ "Very Easy", "Easy", "Medium", "Hard", "Very Hard" ]
                |> ListX.getAt (adventure.difficulty - 1)
                |> Maybe.withDefault "Difficulty Unknown"
    in
    li [ class "card-item" ]
        [ div [ class "card", onClick <| ViewAdventureMap adventure.id ]
            [ div [ class "image", style "background-image" ("url(" ++ adventure.image ++ ")") ] []
            , div [ class "progress-bar" ] [ div [ class "fill", style "width" (String.fromFloat fill ++ "%") ] [] ]
            , div [ class "content" ]
                [ div [ class "title" ] [ text adventure.name ]
                , div [ class "subtitle" ] [ text category ]
                , p [ class "description" ] [ text adventure.description ]
                , div [ class "vertical-bar small" ]
                    [ div [ class "section main" ] [ text difficulty ]
                    , div [ class "section" ] [ wheelchairInfo ]
                    ]
                ]
            ]
        ]


renderAdventureMap : Model -> List Adventure -> Int -> Int -> Bool -> Html Msg
renderAdventureMap model adventures adventureId locationIdx infoToggle =
    let
        maybeAdventure =
            ListX.find (\a -> a.id == adventureId) adventures
    in
    case maybeAdventure of
        Just adventure ->
            let
                header =
                    div [ class "vertical-bar top" ]
                        [ a [ href "/", class "section icon" ]
                            [ home Color.darkGrey 20 ]
                        , div [ class "section main" ]
                            [ div [ class "title" ] [ text adventure.name ]
                            , div [ class "subtitle" ] [ text "Walkway" ]
                            ]
                        , div [ class "section icon" ]
                            [ feedback Color.darkGrey 20 ]
                        , div [ class "section icon" ]
                            [ share Color.darkGrey 20 ]
                        ]

                infoToggleButton =
                    div [ id "info-toggle", onClick ToggleInfo ]
                        [ subject Color.darkGrey 30 ]

                infoBox =
                    if infoToggle then
                        div [ class "info-box" ]
                            [ text location.description ]

                    else
                        div [] []

                location =
                    ListX.getAt (locationIdx - 1) (Nonempty.toList adventure.locations)
                        |> Maybe.withDefault (Nonempty.head adventure.locations)

                previousLocation =
                    if locationIdx > 1 then
                        a [ href <| "/adventures/" ++ String.fromInt adventureId ++ "/locations/" ++ (String.fromInt <| locationIdx - 1) ]
                            [ chevron_left Color.darkGrey 30 ]

                    else
                        a [ class "disabled" ] [ chevron_left Color.darkGrey 30 ]

                nextLocation =
                    if locationIdx < Nonempty.length adventure.locations then
                        a [ href <| "/adventures/" ++ String.fromInt adventureId ++ "/locations/" ++ (String.fromInt <| locationIdx + 1) ]
                            [ chevron_right Color.darkGrey 30 ]

                    else
                        a [ class "disabled" ] [ chevron_right Color.darkGrey 30 ]

                indicatorFor l =
                    div [ class "indicator", classList [ ( "active", l.id == locationIdx ) ] ] []
            in
            div [ id "adventure-map-screen" ]
                [ div [ id "map" ] []
                , header
                , infoToggleButton
                , infoBox
                , div [ class "vertical-bar bottom" ]
                    [ div [ class "section" ] [ previousLocation ]
                    , div [ class "section main" ]
                        [ div [ class "indicators" ] (Nonempty.map indicatorFor adventure.locations |> Nonempty.toList)
                        , div [ class "title" ] [ text location.name ]
                        ]
                    , div [ class "section" ] [ nextLocation ]
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
