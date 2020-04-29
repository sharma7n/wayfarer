module Domain.Computed exposing
    ( Computed
    , fromGlobal
    )

import Domain.Global as Global exposing (Global)


type alias Computed =
    { isDead : Bool
    }


fromGlobal : Global -> Computed
fromGlobal global =
    let
        isDead =
            global.hitPoints <= 0
    in
    { isDead = isDead
    }
