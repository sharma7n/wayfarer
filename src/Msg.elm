module Msg exposing (Msg(..))

import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Effect as Effect exposing (Effect)
import Domain.Event as Event exposing (Event)
import Domain.Map as Map exposing (Map)
import Domain.Monster as Monster exposing (Monster)
import Domain.Requirement as Requirement exposing (Requirement)
import Domain.Scene as Scene exposing (Scene)
import Domain.Shop as Shop exposing (Shop)


type Msg
    = NoOp
    | Decorator (List Requirement) (List Effect) Msg
    | SystemGotDungeon Dungeon
    | SystemGotMonster Monster
    | SystemGotEvent Event
    | UserSelectedMapSelect
    | UserSelectedShop Shop
    | UserSelectedScene Scene
    | UserSelectedMap Map
    | UserSelectedEvent Event
