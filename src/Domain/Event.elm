module Domain.Event exposing (Event)

import Domain.Effect as Effect exposing (Effect)
import Domain.Requirement as Requirement exposing (Requirement)


type alias Event =
    { id : String
    , name : String
    , description : String
    , requirements : List Requirement
    , effects : List Effect
    }
