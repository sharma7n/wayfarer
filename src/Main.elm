module Main exposing (..)

import Browser
import Html exposing (Html)

main : Program () Model msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model = {}

init : flags -> ( Model, Cmd msg )
init _ =
    ( {}, Cmd.none )

view : model -> Html msg
view _ =
    Html.text "Hello, world!"

update : msg -> model -> ( model, Cmd msg )
update msg model =
    ( model, Cmd.none )

subscriptions : model -> Sub msg
subscriptions _ =
    Sub.none