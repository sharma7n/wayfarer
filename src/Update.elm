module Update exposing (update)

import Domain.Scene as Scene exposing (Scene)
import Model exposing (Model)
import Model.Effect
import Msg exposing (Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.scene ) of
        ( Msg.SystemAppliedEffects effects, _ ) ->
            ( model, Cmd.none )
                |> Model.Effect.run effects

        ( Msg.UserSelectedScene scene, _ ) ->
            ( { model | scene = scene }, Cmd.none )
