module Requirement.Global exposing
    ( Requirement(..)
    , toString
    )


type Requirement
    = HitPointCost Int
    | GoldCost Int


toString : Requirement -> String
toString requirement =
    case requirement of
        HitPointCost cost ->
            "HP " ++ String.fromInt cost

        GoldCost cost ->
            "Gold " ++ String.fromInt cost
