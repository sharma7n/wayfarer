module Update exposing (update)

import Domain.Battle as Battle exposing (Battle)
import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Home as Home exposing (Home)
import Domain.Map as Map exposing (Map)
import Domain.Scene as Scene exposing (Scene)
import Lib.Counter as Counter exposing (Counter)
import Model exposing (Model)
import Model.Effect
import Model.Finalizer
import Model.Requirement
import Msg exposing (Msg)
import Random


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.scene ) of
        ( Msg.Decorator requirements effects inner, _ ) ->
            if model |> Model.Requirement.satisfies requirements then
                let
                    ( newModel, newCmd ) =
                        ( model, Cmd.none )
                            |> Model.Requirement.run requirements
                            |> Model.Effect.run effects
                            |> Model.Finalizer.run

                    ( newModel2, newCmdB ) =
                        update inner newModel
                in
                ( newModel2, Cmd.batch [ newCmd, newCmdB ] )

            else
                ( model, Cmd.none )

        ( Msg.UserSelectedMapSelect, Scene.Home _ ) ->
            ( { model | scene = Scene.MapSelect model.scene }, Cmd.none )

        ( Msg.UserSelectedScene scene, _ ) ->
            ( { model | scene = scene }, Cmd.none )

        ( Msg.UserSelectedShop shop, _ ) ->
            ( { model | scene = Scene.Shop shop model.scene }, Cmd.none )

        ( Msg.UserSelectedMap map, Scene.MapSelect _ ) ->
            ( model, Random.generate Msg.SystemGotDungeon (Dungeon.generator map) )

        ( Msg.SystemGotDungeon dungeon, Scene.MapSelect _ ) ->
            ( { model | scene = Scene.Dungeon dungeon }, Cmd.none )

        ( Msg.UserSelectedEvent event, Scene.Dungeon dungeon ) ->
            let
                newDungeon =
                    { dungeon
                        | selectedEvent = Just event
                        , events =
                            dungeon.events
                                |> Counter.remove event
                    }

                newModel =
                    { model | scene = Scene.Dungeon newDungeon }

                ( newModel2, newCmd ) =
                    ( newModel, Cmd.none )
                        |> Model.Requirement.run event.requirements
                        |> Model.Effect.run event.effects
            in
            if model |> Model.Requirement.satisfies event.requirements then
                ( newModel2, newCmd )

            else
                ( model, Cmd.none )

        ( Msg.SystemGotMonster monster, Scene.Dungeon dungeon ) ->
            let
                newScene =
                    Scene.Battle (Battle.new monster) (Scene.Dungeon dungeon)

                newModel =
                    { model | scene = newScene }
            in
            ( newModel, Cmd.none )

        ( Msg.SystemGotBossMonster monster, Scene.Dungeon _ ) ->
            let
                newScene =
                    Scene.BossBattle (Battle.new monster)

                newModel =
                    { model | scene = newScene }
            in
            ( newModel, Cmd.none )

        ( Msg.SystemGotEvent event, Scene.Dungeon dungeon ) ->
            let
                newDungeon =
                    { dungeon | events = dungeon.events |> Counter.insert event }

                newModel =
                    { model | scene = Scene.Dungeon newDungeon }
            in
            ( newModel, Cmd.none )

        ( Msg.UserSelectedRevive, _ ) ->
            ( { model | scene = Scene.Home Home.init }, Cmd.none )

        ( Msg.UserSelectedReincarnate, _ ) ->
            ( Model.init, Cmd.none )

        ( Msg.UserSelectedGarden, Scene.Home _ ) ->
            ( { model | scene = Scene.Garden model.scene }, Cmd.none )

        _ ->
            ( model, Cmd.none )
