module Domain.Dungeon exposing
    ( Dungeon
    , generator
    , modify
    )

import Domain.Event as Event exposing (Event)
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


modify : Effect -> Dungeon -> Dungeon
modify effect dungeon =
    case effect of
        Effect.ChangeSafety safetyDelta ->
            { dungeon | safety = dungeon.safety |> Bounded.add safetyDelta }

        Effect.ChangePath pathDelta ->
            { dungeon | path = dungeon.path |> Bounded.add pathDelta }
