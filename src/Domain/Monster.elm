module Domain.Monster exposing
    ( Monster
    , getById
    )

import Domain.Behavior as Behavior exposing (Behavior)
import Lib.Distribution as Distribution exposing (Distribution)


type alias Monster =
    { id : String
    , name : String
    , hitPoints : Int
    , behaviors : Distribution Behavior
    }


getById : String -> Maybe Monster
getById id =
    case id of
        _ ->
            Nothing



-- MONSTER OBJECTS
