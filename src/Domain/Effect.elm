module Domain.Effect exposing (Effect(..))

import Effect.Battle as Battle
import Effect.Dungeon as Dungeon
import Effect.Global as Global
import Effect.Home as Home


type Effect
    = Global Global.Effect
    | Home Home.Effect
    | Dungeon Dungeon.Effect
    | Battle Battle.Effect
