module Domain.Item exposing
    ( Item
    , getById
    )

import Domain.Effect as Effect exposing (Effect)


type alias Item =
    { id : String
    , name : String
    , description : String
    , cost : Int
    , effects : List Effect
    }


getById : String -> Maybe Item
getById id =
    case id of
        _ ->
            Nothing



-- ITEM OBJECTS
