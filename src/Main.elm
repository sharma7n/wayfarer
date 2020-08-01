module Main exposing (..)

import Browser
import Html

type alias Model =
    {
    }

main : Program () Model msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

-- INIT

init : flags -> ( Model, Cmd msg )
init _ = ( {}, Cmd.none )

-- VIEW

view : Model -> Html.Html msg
view _ = Html.text "Hello, world!"

-- UPDATE

update : msg -> Model -> ( Model, Cmd msg )
update _ model = ( model, Cmd.none )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none