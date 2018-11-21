module Types exposing (Adventure, LatLng, Location, Screen(..), Token)


type Screen
    = Home
    | AdventureMap Int


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


type alias Token =
    String


type alias LatLng =
    { lat : Float
    , lng : Float
    }
