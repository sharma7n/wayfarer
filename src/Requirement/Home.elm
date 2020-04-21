module Requirement.Home exposing
    ( Requirement(..)
    , toString
    )


type Requirement
    = TimeCost Int


toString : Requirement -> String
toString requirement =
    case requirement of
        TimeCost cost ->
            "Time " ++ String.fromInt cost
