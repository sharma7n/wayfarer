module Requirement.Battle exposing
    ( Requirement(..)
    , icon
    )

import Svg exposing (Svg)


type Requirement
    = ActionPointCost Int


icon : Requirement -> Svg msg
icon requirement =
    case requirement of
        ActionPointCost cost ->
            Svg.text <| "AP " ++ String.fromInt cost
