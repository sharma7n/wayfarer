module Domain.Global exposing
    ( Global
    , modifyGold
    , modifyHitPoints
    , modifyTime
    )


type alias Global =
    { time : Int
    , hitPoints : Int
    , gold : Int
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
