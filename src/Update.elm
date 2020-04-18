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

        ( Msg.UserSelectedScene Scene.MapSelect, Scene.Home ) ->
            ( { model | scene = Scene.MapSelect }, Cmd.none )

        ( Msg.UserSelectedScene (Scene.Shop objects Scene.Home), Scene.Home ) ->
            ( { model | scene = Scene.Shop objects Scene.Home }, Cmd.none )

        ( Msg.UserSelectedScene (Scene.Inn Scene.Home), Scene.Home ) ->
            ( { model | scene = Scene.Inn Scene.Home }, Cmd.none )

        _ ->
            ( model, Cmd.none )
