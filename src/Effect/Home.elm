module Effect.Home exposing
    ( Effect(..)
    , toString
    )


type Effect
    = Fane
    | ChangeTime Int


toString : Effect -> String
toString effect =
    case effect of
        Fane ->
            "Fane"

        ChangeTime delta ->
            "Time " ++ String.fromInt delta
