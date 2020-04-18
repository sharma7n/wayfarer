module Model exposing
    ( Model
    , init
    , mapGlobal
    , mapScene
    )

import Domain.Global as Global exposing (Global)
import Domain.Scene as Scene exposing (Scene)


type alias Model =
    { scene : Scene
    , global : Global
    }


init : Model
init =
    { scene = Scene.Home
    , global =
        { time = 3
        , hitPoints = 10
        , gold = 0
        }
    }


mapScene : (Scene -> Scene) -> Model -> Model
mapScene f model =
    { model
        | scene =
            f model.scene
    }


mapGlobal : (Global -> Global) -> Model -> Model
mapGlobal f model =
    { model
        | global =
            f model.global
    }
