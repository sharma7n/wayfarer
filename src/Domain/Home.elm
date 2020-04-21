module Domain.Home exposing
    ( Home
    , init
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
