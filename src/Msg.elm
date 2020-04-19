module Msg exposing (Msg(..))

import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Effect as Effect exposing (Effect)
import Domain.Event as Event exposing (Event)
import Domain.Map as Map exposing (Map)
import Domain.Scene as Scene exposing (Scene)


type Msg
    = SystemAppliedEffects (List Effect)
    | SystemGotDungeon Dungeon
    | UserSelectedScene Scene
    | UserSelectedMap Map
    | UserSelectedEvent Event
