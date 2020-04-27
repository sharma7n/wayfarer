module Model.Finalizer exposing (run)

import Domain.Battle as Battle exposing (Battle)
import Domain.Home as Home exposing (Home)
import Domain.Scene as Scene exposing (Scene)
import Model exposing (Model)
import Msg exposing (Msg)


run : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
run ( model, cmd ) =
    case model.scene of
        Scene.Battle battle ambient ->
            if model.global.hitPoints <= 0 then
                ( { model | scene = Scene.GameOver }, cmd )

            else if battle.monster.hitPoints <= 0 then
                ( { model | scene = ambient }, cmd )

            else if battle.actionPoints <= 0 then
                ( { model | scene = Scene.Battle (battle |> Battle.tick) ambient }, cmd )

            else
                ( model, cmd )

        Scene.BossBattle bossBattle ->
            if model.global.hitPoints <= 0 then
                ( { model | scene = Scene.GameOver }, cmd )

            else if bossBattle.monster.hitPoints <= 0 then
                ( { model | scene = Scene.Home Home.init }, cmd )

            else if bossBattle.actionPoints <= 0 then
                ( { model | scene = Scene.BossBattle (bossBattle |> Battle.tick) }, cmd )

            else
                ( model, cmd )

        _ ->
            ( model, cmd )
