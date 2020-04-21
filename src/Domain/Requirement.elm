module Domain.Requirement exposing
    ( Requirement(..)
    , toString
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


toString : Requirement -> String
toString requirement =
    case requirement of
        Global global ->
            Global.toString global

        Home home ->
            Home.toString home

        Dungeon dungeon ->
            Dungeon.toString dungeon

        Battle battle ->
            Battle.toString battle
