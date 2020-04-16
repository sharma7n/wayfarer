module View exposing (view)

import Element exposing (Element)
import Html exposing (Html)
import Model exposing (Model)
import Msg exposing (Msg)


view : Model -> Html Msg
view model =
    Element.layout
        []
        (viewElement model)


viewElement : Model -> Element Msg
viewElement model =
    Element.text "Hello, world!"
