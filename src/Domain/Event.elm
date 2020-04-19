module Domain.Event exposing
    ( Event
    , generator
    )

import Domain.Effect as Effect exposing (Effect)
import Domain.Map as Map exposing (Map)
import Domain.Requirement as Requirement exposing (Requirement)
import Lib.Distribution as Distribution exposing (Distribution)
import Random


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
            ( 1, cavern )
            []



-- EVENT OBJECTS


cavern : Event
cavern =
    { id = "cavern"
    , name = "Cavern"
    , description = "a cavern"
    , image = "cavern"
    , requirements = []
    , effects = []
    }
