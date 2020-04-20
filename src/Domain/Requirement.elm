module Domain.Requirement exposing
    ( Requirement(..)
    , icon
    )

import Requirement.Battle as Battle
import Requirement.Dungeon as Dungeon
import Requirement.Global as Global
import Requirement.Home as Home
import Svg exposing (Svg)


type Requirement
    = Global Global.Requirement
    | Home Home.Requirement
    | Dungeon Dungeon.Requirement
    | Battle Battle.Requirement


icon : Requirement -> Svg msg
icon requirement =
    case requirement of
        Global global ->
            Global.icon global

        Home home ->
            Home.icon home

        Dungeon dungeon ->
            Dungeon.icon dungeon

        Battle battle ->
            Battle.icon battle
