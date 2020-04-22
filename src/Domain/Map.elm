module Domain.Map exposing
    ( Map
    , choice
    , toString
    )

import Domain.Choice as Choice exposing (Choice)
import Domain.Effect as Effect exposing (Effect)
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


choice : Map -> Choice
choice map =
    { label = toString map
    , requirements = []
    , effects = []
    }
