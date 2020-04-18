module Domain.Global exposing
    ( Global
    , modifyHitPoints
    , modifyTime
    )


type alias Global =
    { time : Int
    , hitPoints : Int
    }


modifyTime : Int -> Global -> Global
modifyTime timeDelta model =
    let
        newTime =
            model.time
                |> (\t -> t + timeDelta)
                |> max 0
    in
    { model
        | time =
            newTime
    }


modifyHitPoints : Int -> Global -> Global
modifyHitPoints hitPointDelta model =
    let
        newHitPoints =
            model.hitPoints
                |> (\h -> h + hitPointDelta)
                |> max 0
    in
    { model
        | hitPoints =
            newHitPoints
    }
