module Model.Finalizer exposing (run)

import Domain.Battle as Battle exposing (Battle)
import Domain.Home as Home exposing (Home)
import Domain.Monster as Monster exposing (Monster)
import Domain.Scene as Scene exposing (Scene)
import Lib.Bounded as Bounded
import Model exposing (Model)
import Msg exposing (Msg)
import Random


run : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
run ( model, cmd ) =
    case model.scene of
        Scene.Dungeon dungeon ->
            if dungeon.safety <= 0 then
                let
                    bossCmd =
                        Random.generate Msg.SystemGotBossMonster (Monster.bossGenerator dungeon.map)
                in
                ( model, Cmd.batch [ cmd, bossCmd ] )

            else
                ( model, cmd )

        Scene.Battle battle ambient ->
            if battle.monster.hitPoints <= 0 then
                ( { model | scene = ambient }, cmd )

            else if battle.actionPoints <= 0 then
                let
                    damage =
                        battle.monster.attack |> Bounded.subtract battle.generatedBlock

                    newHitPoints =
                        model.global.hitPoints |> Bounded.subtract damage

                    newScene =
                        Scene.Battle (battle |> Battle.tick) ambient

                    global =
                        model.global

                    newGlobal =
                        { global | hitPoints = newHitPoints }

                    newModel =
                        { model
                            | scene = newScene
                            , global = newGlobal
                        }
                in
                ( newModel, cmd )

            else
                ( model, cmd )

        Scene.BossBattle bossBattle ->
            if bossBattle.monster.hitPoints <= 0 then
                ( { model | scene = Scene.Home Home.init }, cmd )

            else if bossBattle.actionPoints <= 0 then
                let
                    damage =
                        bossBattle.monster.attack |> Bounded.subtract bossBattle.generatedBlock

                    newHitPoints =
                        model.global.hitPoints |> Bounded.subtract damage

                    newScene =
                        Scene.BossBattle (bossBattle |> Battle.tick)

                    global =
                        model.global

                    newGlobal =
                        { global | hitPoints = newHitPoints }

                    newModel =
                        { model
                            | scene = newScene
                            , global = newGlobal
                        }
                in
                ( newModel, cmd )

            else
                ( model, cmd )

        _ ->
            ( model, cmd )
