module Domain.Choice exposing
    ( Choice
    , choice
    )

import Domain.Effect as Effect exposing (Effect)
import Domain.Requirement as Requirement exposing (Requirement)


type alias Choice =
    { label : String
    , requirements : List Requirement
    , effects : List Effect
    }


choice : String -> List Requirement -> List Effect -> Choice
choice label requirements effects =
    { label = label
    , requirements = requirements
    , effects = effects
    }
