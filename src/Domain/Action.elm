module Domain.Action exposing
    ( Action
    , getById
    )

import Domain.Effect as Effect exposing (Effect)
import Domain.Requirement as Requirement exposing (Requirement)
import Effect.Battle
import Effect.Global
import Requirement.Battle
import Requirement.Global


type alias Action =
    { id : String
    , name : String
    , requirements : List Requirement
    , effects : List Effect
    }


getById : String -> Maybe Action
getById id =
    case id of
        "attack" ->
            Just attack

        "defend" ->
            Just defend

        _ ->
            Nothing



-- ACTION OBJECTS


attack : Action
attack =
    { id = "attack"
    , name = "Attack"
    , requirements =
        [ Requirement.Battle <| Requirement.Battle.ActionPointCost 1
        ]
    , effects =
        [ Effect.Battle <| Effect.Battle.DealDamage 1
        ]
    }


defend : Action
defend =
    { id = "defend"
    , name = "Defend"
    , requirements =
        [ Requirement.Battle <| Requirement.Battle.ActionPointCost 1
        ]
    , effects =
        [ Effect.Battle <| Effect.Battle.ChangeGeneratedBlock 1
        ]
    }
