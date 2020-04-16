module Model exposing
    ( Model
    , init
    )

import Domain.Scene as Scene exposing (Scene)


type alias Model =
    { scene : Scene
    }


init : Model
init =
    { scene = Scene.Home
    }
