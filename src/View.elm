module View exposing (view)

import Element exposing (Element)
import Html exposing (Html)
import Model exposing (Model)
import Msg exposing (Msg)
import App.Ui as Ui exposing (Ui)


view : Model -> Html Msg
view model =
    Ui.layout <| viewUi model

viewUi : Model -> Ui Msg
viewUi model =
    Ui.screen
        { header =
            Ui.header <| Ui.label "Header"
        , context =
            Ui.context []
        , stage =
            Ui.stage
                { label =
                    Ui.label "Stage"
                , image =
                    Ui.image "Image"
                , description =
                    Ui.description "Description"
                }
        , choices =
            []
        }