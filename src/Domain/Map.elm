module Domain.Map exposing
    ( Map
    , toString
    )

import Domain.Environ as Environ exposing (Environ)


type alias Map =
    { hash : String
    , environ : Environ
    , level : Int
    }


toString : Map -> String
toString map =
    [ Environ.toString map.environ
    , "Lv. " ++ String.fromInt map.level
    ]
        |> String.join " "
