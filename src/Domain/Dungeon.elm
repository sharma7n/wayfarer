module Domain.Dungeon exposing
    ( Dungeon
    , generator
    )

import Domain.Event as Event exposing (Event)
import Domain.Global as Global exposing (Global)
import Domain.Map as Map exposing (Map)
import Effect.Dungeon as Effect exposing (Effect)
import Lib.Bounded as Bounded
import Random


type alias Dungeon =
    { map : Map
    , safety : Int
    , path : Int
    , events : List Event
    , selectedEvent : Maybe Event
    }


generator : Map -> Random.Generator Dungeon
generator map =
    let
        mapGenerator =
            Random.constant map

        safetyGenerator =
            Random.int (10 + map.level) (10 + (2 * map.level))

        pathGenerator =
            Random.constant 0

        eventsGenerator =
            Random.list 3 (Event.generator map)

        selectedEventGenerator =
            Random.constant Nothing
    in
    Random.map5 Dungeon
        mapGenerator
        safetyGenerator
        pathGenerator
        eventsGenerator
        selectedEventGenerator
