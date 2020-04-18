module View exposing (view)

import App.Ui as Ui exposing (Ui)
import Element exposing (Element)
import Html exposing (Html)
import Model exposing (Model)
import Msg exposing (Msg)


view : Model -> Html Msg
view model =
    Ui.layout <| viewUi model


viewUi : Model -> Ui Msg
viewUi model =
    Ui.screen
        { header =
            Ui.header <| Ui.label "Home"
        , context =
            Ui.context
                [ { label = Ui.label "HP"
                  , quantity = Ui.quantity 10
                  }
                ]
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
