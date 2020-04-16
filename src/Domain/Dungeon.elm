module Domain.Dungeon exposing (Dungeon)

import Domain.Event as Event exposing (Event)
import Domain.Map as Map exposing (Map)


type alias Dungeon =
    { map : Map
    , safety : Int
    , path : Int
    , events : List Event
    }
