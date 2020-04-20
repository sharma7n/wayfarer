module Domain.Event exposing
    ( Event
    , generator
    )

import Domain.Effect as Effect exposing (Effect)
import Domain.Map as Map exposing (Map)
import Domain.Requirement as Requirement exposing (Requirement)
import Effect.Dungeon
import Effect.Global
import Lib.Distribution as Distribution exposing (Distribution)
import Random
import Requirement.Dungeon
import Requirement.Global


type alias Event =
    { id : String
    , name : String
    , description : String
    , image : String
    , requirements : List Requirement
    , effects : List Effect
    }


generator : Map -> Random.Generator Event
generator _ =
    Distribution.random <|
        Distribution.new
            ( 1, encounter )
            [ ( 1, cavern )
            , ( 1, ropeBridge )
            ]



-- EVENT OBJECTS


encounter : Event
encounter =
    { id = "encounter"
    , name = "Encounter"
    , description = "random encounter"
    , image = "encounter"
    , requirements =
        [ Requirement.Dungeon <| Requirement.Dungeon.SafetyCost 1
        ]
    , effects =
        [ Effect.Dungeon <| Effect.Dungeon.RandomEncounter
        ]
    }


cavern : Event
cavern =
    { id = "cavern"
    , name = "Cavern"
    , description = "a cavern"
    , image = "cavern"
    , requirements =
        [ Requirement.Dungeon <| Requirement.Dungeon.SafetyCost 1
        ]
    , effects =
        []
    }


ropeBridge : Event
ropeBridge =
    { id = "ropeBridge"
    , name = "Rope Bridge"
    , description = "a rope bridge"
    , image = "ropeBridge"
    , requirements =
        [ Requirement.Dungeon <| Requirement.Dungeon.SafetyCost 1
        ]
    , effects =
        [ Effect.Dungeon <| Effect.Dungeon.ChangePath 1
        ]
    }
