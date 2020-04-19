module Domain.Behavior exposing
    ( Behavior(..)
    , toString
    )


type Behavior
    = DoNothing
    | Attack


toString : Behavior -> String
toString behavior =
    case behavior of
        DoNothing ->
            "Do Nothing"

        Attack ->
            "Attack"
