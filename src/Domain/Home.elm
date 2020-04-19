module Domain.Home exposing
    ( Home
    , init
    , modify
    )

import Effect.Home as Effect exposing (Effect)
import Lib.Bounded as Bounded


type alias Home =
    { time : Int
    }


init : Home
init =
    { time = 3
    }


modify : Effect -> Home -> Home
modify effect home =
    case effect of
        Effect.ChangeTime timeDelta ->
            { home | time = home.time |> Bounded.add timeDelta }
