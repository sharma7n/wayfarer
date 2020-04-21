module Requirement.Battle exposing
    ( Requirement(..)
    , toString
    )


type Requirement
    = ActionPointCost Int


toString : Requirement -> String
toString requirement =
    case requirement of
        ActionPointCost cost ->
            "AP " ++ String.fromInt cost
