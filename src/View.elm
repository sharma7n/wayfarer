module View exposing (view)

import App.Scene
import App.Ui as Ui exposing (Ui)
import Html exposing (Html)
import Model exposing (Model)
import Msg exposing (Msg)


view : Model -> Html Msg
view model =
    Ui.layout <| viewUi model


viewUi : Model -> Ui Msg
viewUi model =
    App.Scene.view model.scene model.global
