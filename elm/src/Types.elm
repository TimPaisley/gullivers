module Types exposing (Adventure, AdventureCategory(..), CardDisplay, Filter(..), GeoData(..), LatLng, Location, Screen(..), Sort(..), Toggle(..), Token, allFilters, allSorts, filterToString, sortToString)

import List.Nonempty exposing (Nonempty)


type Screen
    = Home
    | AdventureMap Int Int


type alias CardDisplay =
    { toggle : Maybe Toggle
    , filter : Filter
    , sort : Sort
    }


type Toggle
    = Filter
    | Sort


type Filter
    = All
    | Accessible
    | Simple


allFilters : List Filter
allFilters =
    [ All, Accessible, Simple ]


filterToString : Filter -> String
filterToString filter =
    case filter of
        All ->
            "All"

        Accessible ->
            "Accessible"

        Simple ->
            "Simple"


type Sort
    = Name
    | Size
    | Difficulty


allSorts : List Sort
allSorts =
    [ Name, Size, Difficulty ]


sortToString : Sort -> String
sortToString sort =
    case sort of
        Name ->
            "Name"

        Size ->
            "Size"

        Difficulty ->
            "Difficulty"


type alias Adventure =
    { id : Int
    , name : String
    , image : String
    , category : AdventureCategory
    , description : String
    , locations : Nonempty Location
    , badgeUrl : String
    , difficulty : Int
    , wheelchairAccessible : Bool
    }


type AdventureCategory
    = Path
    | Collection


type alias Location =
    { id : Int
    , name : String
    , description : String
    , latLng : LatLng
    }


type alias Token =
    String


type GeoData
    = NotAsked
    | Loading
    | Failure String
    | Success LatLng


type alias LatLng =
    { lat : Float
    , lng : Float
    }