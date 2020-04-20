module Msg exposing (Msg(..))

import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Effect as Effect exposing (Effect)
import Domain.Event as Event exposing (Event)
import Domain.Map as Map exposing (Map)
import Domain.Monster as Monster exposing (Monster)
import Domain.Scene as Scene exposing (Scene)


type Msg
    = SystemAppliedEffects (List Effect)
    | SystemGotDungeon Dungeon
    | SystemGotMonster Monster
    | UserSelectedScene Scene
    | UserSelectedMap Map
    | UserSelectedEvent Event
