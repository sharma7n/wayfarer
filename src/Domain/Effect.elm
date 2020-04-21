module Domain.Effect exposing
    ( Effect(..)
    , toString
    )

import Effect.Battle as Battle
import Effect.Dungeon as Dungeon
import Effect.Global as Global
import Effect.Home as Home


type Effect
    = Global Global.Effect
    | Home Home.Effect
    | Dungeon Dungeon.Effect
    | Battle Battle.Effect


toString : Effect -> String
toString effect =
    case effect of
        Global global ->
            Global.toString global

        Home home ->
            Home.toString home

        Dungeon dungeon ->
            Dungeon.toString dungeon

        Battle battle ->
            Battle.toString battle
