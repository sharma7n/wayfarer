module Lib.Ui exposing
    ( Ui
    , none
    )

import Element exposing (Element)
import Element.Background
import Element.Font


type Ui msg
    = Ui (Element msg)


none : Ui msg
none =
    Ui <| Element.none
