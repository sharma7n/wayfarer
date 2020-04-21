module Requirement.Dungeon exposing
    ( Requirement(..)
    , toString
    )


type Requirement
    = SafetyCost Int
    | PathCost Int


toString : Requirement -> String
toString requirement =
    case requirement of
        SafetyCost cost ->
            "Safety " ++ String.fromInt cost

        PathCost cost ->
            "Path " ++ String.fromInt cost
