module Update exposing (update)

import Domain.Battle as Battle exposing (Battle)
import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Map as Map exposing (Map)
import Domain.Scene as Scene exposing (Scene)
import Model exposing (Model)
import Model.Effect
import Msg exposing (Msg)
import Random


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.scene ) of
        ( Msg.SystemAppliedEffects effects, _ ) ->
            ( model, Cmd.none )
                |> Model.Effect.run effects

        ( Msg.UserSelectedScene scene, _ ) ->
            ( { model | scene = scene }, Cmd.none )

        ( Msg.UserSelectedMap map, Scene.MapSelect _ ) ->
            ( model, Random.generate Msg.SystemGotDungeon (Dungeon.generator map) )

        ( Msg.SystemGotDungeon dungeon, Scene.MapSelect _ ) ->
            ( { model | scene = Scene.Dungeon dungeon }, Cmd.none )

        ( Msg.UserSelectedEvent event, Scene.Dungeon dungeon ) ->
            let
                newDungeon =
                    { dungeon | selectedEvent = Just event }

                newModel =
                    { model | scene = Scene.Dungeon newDungeon }
            in
            ( newModel, Cmd.none )
                |> Model.Effect.run event.effects

        ( Msg.SystemGotMonster monster, Scene.Dungeon dungeon ) ->
            let
                newScene =
                    Scene.Battle (Battle.new monster) (Scene.Dungeon dungeon)

                newModel =
                    { model | scene = newScene }
            in
            ( newModel, Cmd.none )

        _ ->
            ( model, Cmd.none )
