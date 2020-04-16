module Domain.Dungeon exposing (Dungeon)

import Lib.Counter as Counter exposing (Counter)


type alias Dungeon =
    { safety : Int
    , path : Int
    , events : Counter Event
    }
