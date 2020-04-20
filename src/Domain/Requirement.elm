module Domain.Requirement exposing (Requirement(..))

import Requirement.Battle as Battle
import Requirement.Dungeon as Dungeon
import Requirement.Global as Global
import Requirement.Home as Home


type Requirement
    = Global Global.Requirement
    | Home Home.Requirement
    | Dungeon Dungeon.Requirement
    | Battle Battle.Requirement
