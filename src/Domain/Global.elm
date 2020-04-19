module Domain.Global exposing
    ( Global
    , modifyGold
    , modifyHitPoints
    , modifyTime
    )

import Domain.Equipment as Equipment exposing (Equipment)
import Domain.Item as Item exposing (Item)
import Domain.Map as Map exposing (Map)
import Domain.Skill as Skill exposing (Skill)


type alias Global =
    { time : Int
    , hitPoints : Int
    , gold : Int
    , maps : List Map
    , items : List Item
    , equipment : List Equipment
    , skills : List Skill
    }


addDeltaBounded : Int -> Int -> Int
addDeltaBounded x y =
    max 0 (x + y)


modifyTime : Int -> Global -> Global
modifyTime timeDelta global =
    { global
        | time =
            global.time |> addDeltaBounded timeDelta
    }


modifyHitPoints : Int -> Global -> Global
modifyHitPoints hitPointDelta global =
    { global
        | hitPoints =
            global.hitPoints |> addDeltaBounded hitPointDelta
    }


modifyGold : Int -> Global -> Global
modifyGold goldDelta global =
    { global
        | gold =
            global.gold |> addDeltaBounded goldDelta
    }
