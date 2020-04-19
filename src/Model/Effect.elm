module Model.Effect exposing (run)

import Domain.Battle as Battle exposing (Battle)
import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Effect as Effect exposing (Effect)
import Domain.Global as Global exposing (Global)
import Domain.Home as Home exposing (Home)
import Domain.Scene as Scene exposing (Scene)
import Model exposing (Model)
import Msg exposing (Msg)


run : List Effect -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
run effects ( model, cmd ) =
    effects
        |> List.foldr runOne ( model, cmd )


runOne : Effect -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
runOne effect ( model, cmd ) =
    case ( effect, model.scene ) of
        ( Effect.Global globalEffect, _ ) ->
            ( { model | global = model.global |> Global.modify globalEffect }, cmd )

        ( Effect.Home homeEffect, Scene.Home home ) ->
            ( { model | scene = Scene.Home (home |> Home.modify homeEffect) }, cmd )

        ( Effect.Dungeon dungeonEffect, Scene.Dungeon dungeon ) ->
            ( { model | scene = Scene.Dungeon (dungeon |> Dungeon.modify dungeonEffect) }, cmd )

        ( Effect.Battle battleEffect, Scene.Battle battle ambient ) ->
            ( { model | scene = Scene.Battle (battle |> Battle.modify battleEffect) ambient }, cmd )

        ( Effect.Battle battleEffect, Scene.BossBattle bossBattle ) ->
            ( { model | scene = Scene.BossBattle (bossBattle |> Battle.modify battleEffect) }, cmd )

        _ ->
            ( model, cmd )
