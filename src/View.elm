module View exposing (view)

import Html exposing (Html)
import Model exposing (Model)
import Msg exposing (Msg)
import View.Scene
import View.Ui as Ui exposing (Ui)


view : Model -> Html Msg
view model =
    Ui.layout <| viewUi model


viewUi : Model -> Ui Msg
viewUi model =
    View.Scene.view model.scene model.global
