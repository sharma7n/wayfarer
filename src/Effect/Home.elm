module Effect.Home exposing
    ( Effect(..)
    , toString
    )


type Effect
    = ChangeTime Int


toString : Effect -> String
toString effect =
    case effect of
        ChangeTime delta ->
            "Time " ++ String.fromInt delta
