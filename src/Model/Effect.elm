module Model.Effect exposing (run)

import Domain.Effect as Effect exposing (Effect)
import Domain.Global as Global exposing (Global)
import Model exposing (Model)
import Msg exposing (Msg)


run : List Effect -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
run effects ( model, cmd ) =
    effects
        |> List.foldr runOne ( model, cmd )


runOne : Effect -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
runOne effect ( model, cmd ) =
    case effect of
        Effect.ChangeTime timeDelta ->
            let
                newModel =
                    model
                        |> Model.mapGlobal (Global.modifyTime timeDelta)
            in
            ( newModel, cmd )

        Effect.ChangeHitPoints hitPointDelta ->
            let
                newModel =
                    model
                        |> Model.mapGlobal (Global.modifyHitPoints hitPointDelta)
            in
            ( newModel, cmd )
