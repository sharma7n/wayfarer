module Domain.Equipment exposing
    ( Equipment
    , getById
    )

import Domain.Passive as Passive exposing (Passive)


type alias Equipment =
    { id : String
    , name : String
    , description : String
    , cost : Int
    , passives : List Passive
    }


getById : String -> Maybe Equipment
getById id =
    case id of
        _ ->
            Nothing
