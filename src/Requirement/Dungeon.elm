module Requirement.Dungeon exposing
    ( Requirement(..)
    , icon
    )

import Svg exposing (Svg)


type Requirement
    = SafetyCost Int
    | PathCost Int


icon : Requirement -> Svg msg
icon requirement =
    case requirement of
        SafetyCost cost ->
            Svg.text <| "Safety " ++ String.fromInt cost

        PathCost cost ->
            Svg.text <| "Path " ++ String.fromInt cost
