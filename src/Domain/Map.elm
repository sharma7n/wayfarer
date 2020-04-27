module Domain.Map exposing
    ( Map
    , beginning
    , getByHash
    , toString
    )

import Domain.Effect as Effect exposing (Effect)
import Domain.Environ as Environ exposing (Environ)
import Effect.Fane


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


getByHash : String -> Maybe Map
getByHash hash =
    case hash of
        "beginning" ->
            Just beginning

        _ ->
            Nothing



-- MAP OBJECTS


beginning : Map
beginning =
    { hash = "beginning"
    , environ = Environ.Cave
    , level = 1
    }
