module Domain.Map exposing
    ( Map
    , toString
    )


type alias Map =
    { hash : String
    , level : Int
    }


toString : Map -> String
toString map =
    "Map " ++ String.fromInt map.level
