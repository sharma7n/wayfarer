module Model.Fane exposing (runEffect)

import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Global as Global exposing (Global)
import Domain.Map as Map exposing (Map)
import Effect.Fane as Effect exposing (Effect)
import Lib.Bounded as Bounded
import Model exposing (Model)
import Msg exposing (Msg)
import Random


runEffect : Effect -> ( Global, Cmd Msg ) -> ( Global, Cmd Msg )
runEffect effect ( global, cmd ) =
    case effect of
        Effect.SelectMap mapHash ->
            let
                getRandomDungeon =
                    case Map.getByHash mapHash of
                        Just map ->
                            Random.generate Msg.SystemGotDungeon (Dungeon.generator map)

                        Nothing ->
                            Cmd.none
            in
            ( global
            , Cmd.batch [ cmd, getRandomDungeon ]
            )
