module Main exposing (..)

import Browser
import Model exposing (Model)
import Msg exposing (Msg)
import Subscriptions
import Update
import View


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = Subscriptions.subscriptions
        }


init : flags -> ( Model, Cmd msg )
init _ =
    ( Model.init, Cmd.none )
