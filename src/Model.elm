module Model exposing
    ( Model
    , init
    , mapGlobal
    , mapScene
    )

import Domain.Equipment as Equipment exposing (Equipment)
import Domain.Global as Global exposing (Global)
import Domain.Home as Home exposing (Home)
import Domain.Item as Item exposing (Item)
import Domain.Map as Map exposing (Map)
import Domain.Scene as Scene exposing (Scene)
import Domain.Skill as Skill exposing (Skill)


type alias Model =
    { scene : Scene
    , global : Global
    }


init : Model
init =
    { scene = Scene.Home Home.init
    , global = Global.init
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
