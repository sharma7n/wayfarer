module Requirement.Global exposing
    ( Requirement(..)
    , icon
    )

import Svg exposing (Svg)


type Requirement
    = HitPointCost Int
    | GoldCost Int


icon : Requirement -> Svg msg
icon requirement =
    case requirement of
        HitPointCost cost ->
            Svg.text <| "HP " ++ String.fromInt cost

        GoldCost cost ->
            Svg.text <| "Gold " ++ String.fromInt cost
