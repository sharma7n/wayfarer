module Requirement.Home exposing
    ( Requirement(..)
    , icon
    )

import Svg exposing (Svg)


type Requirement
    = TimeCost Int


icon : Requirement -> Svg msg
icon requirement =
    case requirement of
        TimeCost cost ->
            Svg.text <| "Time " ++ String.fromInt cost
