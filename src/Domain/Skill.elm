module Domain.Skill exposing
    ( Skill
    , getById
    )

import Domain.Effect as Effect exposing (Effect)
import Domain.Usage as Usage exposing (Usage)


type alias Skill =
    { id : String
    , name : String
    , description : String
    , actionCost : Int
    , usage : List Usage
    , effects : List Effect
    }


getById : String -> Maybe Skill
getById id =
    case id of
        _ ->
            Nothing



-- SKILL OBJECTS
