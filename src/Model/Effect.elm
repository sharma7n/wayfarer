module Model.Effect exposing (run)

import Domain.Battle as Battle exposing (Battle)
import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Effect as Effect exposing (Effect)
import Domain.Global as Global exposing (Global)
import Domain.Home as Home exposing (Home)
import Domain.Scene as Scene exposing (Scene)
import Effect.Battle
import Effect.Dungeon
import Effect.Global
import Effect.Home
import Lib.Bounded as Bounded
import Model exposing (Model)
import Model.Battle
import Model.Dungeon
import Model.Fane
import Model.Global
import Model.Home
import Msg exposing (Msg)


run : List Effect -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
run effects ( model, cmd ) =
    effects
        |> List.foldr runOne ( model, cmd )


runOne : Effect -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
runOne effect ( model, cmd ) =
    case ( effect, model.scene ) of
        ( Effect.Global globalEffect, _ ) ->
            let
                ( newGlobal, newCmd ) =
                    ( model.global, cmd )
                        |> Model.Global.runEffect globalEffect
            in
            ( { model | global = newGlobal }, newCmd )

        ( Effect.Home homeEffect, Scene.Home home ) ->
            let
                ( newGlobal, newHome, newCmd ) =
                    ( model.global, home, cmd )
                        |> Model.Home.runEffect homeEffect

                newModel =
                    { model
                        | global = newGlobal
                        , scene = Scene.Home newHome
                    }
            in
            ( newModel, newCmd )

        ( Effect.Fane faneEffect, Scene.MapSelect _ ) ->
            let
                ( newGlobal, newCmd ) =
                    ( model.global, cmd )
                        |> Model.Fane.runEffect faneEffect

                newModel =
                    { model
                        | global = newGlobal
                    }
            in
            ( newModel, newCmd )

        ( Effect.Dungeon dungeonEffect, Scene.Dungeon dungeon ) ->
            let
                ( newGlobal, newDungeon, newCmd ) =
                    ( model.global, dungeon, cmd )
                        |> Model.Dungeon.runEffect dungeonEffect

                newModel =
                    { model
                        | global = newGlobal
                        , scene = Scene.Dungeon newDungeon
                    }
            in
            ( newModel, newCmd )

        ( Effect.Battle battleEffect, Scene.Battle battle ambient ) ->
            let
                ( newGlobal, newBattle, newCmd ) =
                    ( model.global, battle, cmd )
                        |> Model.Battle.runEffect battleEffect

                newModel =
                    { model
                        | global = newGlobal
                        , scene = Scene.Battle newBattle ambient
                    }
            in
            ( newModel, newCmd )

        ( Effect.Battle battleEffect, Scene.BossBattle bossBattle ) ->
            let
                ( newGlobal, newBossBattle, newCmd ) =
                    ( model.global, bossBattle, cmd )
                        |> Model.Battle.runEffect battleEffect

                newModel =
                    { model
                        | global = newGlobal
                        , scene = Scene.BossBattle newBossBattle
                    }
            in
            ( newModel, newCmd )

        _ ->
            ( model, cmd )
