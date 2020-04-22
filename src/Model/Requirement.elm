module Model.Requirement exposing
    ( run
    , satisfies
    )

import Domain.Global as Global exposing (Global)
import Domain.Requirement as Requirement exposing (Requirement)
import Domain.Scene as Scene exposing (Scene)
import Model exposing (Model)
import Model.Battle
import Model.Dungeon
import Model.Global
import Model.Home
import Msg exposing (Msg)


run : List Requirement -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
run requirements ( model, cmd ) =
    requirements
        |> List.foldr runOne ( model, cmd )


runOne : Requirement -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
runOne requirement ( model, cmd ) =
    case ( requirement, model.scene ) of
        ( Requirement.Global globalRequirement, _ ) ->
            let
                ( newGlobal, newCmd ) =
                    ( model.global, cmd )
                        |> Model.Global.runRequirement globalRequirement
            in
            ( { model | global = newGlobal }, newCmd )

        ( Requirement.Home homeRequirement, Scene.Home home ) ->
            let
                ( newGlobal, newHome, newCmd ) =
                    ( model.global, home, cmd )
                        |> Model.Home.runRequirement homeRequirement

                newModel =
                    { model
                        | global = newGlobal
                        , scene = Scene.Home newHome
                    }
            in
            ( newModel, newCmd )

        ( Requirement.Dungeon dungeonRequirement, Scene.Dungeon dungeon ) ->
            let
                ( newGlobal, newDungeon, newCmd ) =
                    ( model.global, dungeon, cmd )
                        |> Model.Dungeon.runRequirement dungeonRequirement

                newModel =
                    { model
                        | global = newGlobal
                        , scene = Scene.Dungeon newDungeon
                    }
            in
            ( newModel, newCmd )

        ( Requirement.Battle battleRequirement, Scene.Battle battle ambient ) ->
            let
                ( newGlobal, newBattle, newCmd ) =
                    ( model.global, battle, cmd )
                        |> Model.Battle.runRequirement battleRequirement

                newModel =
                    { model
                        | global = newGlobal
                        , scene = Scene.Battle newBattle ambient
                    }
            in
            ( newModel, newCmd )

        ( Requirement.Battle battleRequirement, Scene.BossBattle bossBattle ) ->
            let
                ( newGlobal, newBossBattle, newCmd ) =
                    ( model.global, bossBattle, cmd )
                        |> Model.Battle.runRequirement battleRequirement

                newModel =
                    { model
                        | global = newGlobal
                        , scene = Scene.BossBattle newBossBattle
                    }
            in
            ( newModel, newCmd )

        _ ->
            ( model, cmd )


satisfies : List Requirement -> Model -> Bool
satisfies requirements model =
    requirements
        |> List.all (satisfiesOne model)


satisfiesOne : Model -> Requirement -> Bool
satisfiesOne model requirement =
    case ( requirement, model.scene ) of
        ( Requirement.Global globalRequirement, _ ) ->
            model.global
                |> Model.Global.satisfiesRequirement globalRequirement

        ( Requirement.Home homeRequirement, Scene.Home home ) ->
            home
                |> Model.Home.satisfiesRequirement homeRequirement

        ( Requirement.Dungeon dungeonRequirement, Scene.Dungeon dungeon ) ->
            dungeon
                |> Model.Dungeon.satisfiesRequirement dungeonRequirement

        ( Requirement.Battle battleRequirement, Scene.Battle battle _ ) ->
            battle
                |> Model.Battle.satisfiesRequirement battleRequirement

        ( Requirement.Battle battleRequirement, Scene.BossBattle bossBattle ) ->
            bossBattle
                |> Model.Battle.satisfiesRequirement battleRequirement

        _ ->
            False
