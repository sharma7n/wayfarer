module Effect.Global exposing
    ( Effect(..)
    , toString
    )


type Effect
    = ChangeHitPoints Int
    | ChangeGold Int


toString : Effect -> String
toString effect =
    case effect of
        ChangeHitPoints delta ->
            "HP " ++ String.fromInt delta

        ChangeGold delta ->
            "Gold " ++ String.fromInt delta
