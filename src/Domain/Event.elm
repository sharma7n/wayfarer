module Domain.Event exposing
    ( Event
    , generator
    , getById
    )

import Domain.Effect as Effect exposing (Effect)
import Domain.Environ as Environ exposing (Environ)
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
    , environs : List Environ
    , requirements : List Requirement
    , effects : List Effect
    }


generator : Map -> Random.Generator Event
generator map =
    case map.environ of
        Environ.Cave ->
            Distribution.random <|
                Distribution.new
                    ( 1, encounter )
                    [ ( 1, cavern )
                    , ( 1, ropeBridge )
                    ]

        _ ->
            Random.constant empty


getById : String -> Maybe Event
getById id =
    case id of
        "empty" ->
            Just empty

        "encounter" ->
            Just encounter

        "cavern" ->
            Just cavern

        "ropeBridge" ->
            Just ropeBridge

        _ ->
            Nothing



-- EVENT OBJECTS


empty : Event
empty =
    { id = "empty"
    , name = "Empty"
    , description = "An empty room."
    , image = "empty"
    , environs = []
    , requirements = []
    , effects = []
    }


encounter : Event
encounter =
    { id = "encounter"
    , name = "Encounter"
    , description = "random encounter"
    , image = "encounter"
    , environs = Environ.all
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
    , environs = [ Environ.Cave ]
    , requirements =
        [ Requirement.Dungeon <| Requirement.Dungeon.SafetyCost 1
        ]
    , effects =
        [ Effect.Dungeon <| Effect.Dungeon.AppendEvents 2
        ]
    }


ropeBridge : Event
ropeBridge =
    { id = "ropeBridge"
    , name = "Rope Bridge"
    , description = "a rope bridge"
    , image = "ropeBridge"
    , environs = [ Environ.Cave ]
    , requirements =
        [ Requirement.Dungeon <| Requirement.Dungeon.SafetyCost 1
        ]
    , effects =
        [ Effect.Dungeon <| Effect.Dungeon.AppendEvents 1
        , Effect.Dungeon <| Effect.Dungeon.ChangePath 1
        ]
    }
