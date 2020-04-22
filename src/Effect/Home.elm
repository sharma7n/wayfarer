module Effect.Home exposing
    ( Effect(..)
    , toString
    )


type Effect
    = Fane
    | Shop (List ( String, String ))
    | ChangeTime Int


toString : Effect -> String
toString effect =
    case effect of
        Fane ->
            "Fane"

        Shop _ ->
            "Shop"

        ChangeTime delta ->
            "Time " ++ String.fromInt delta
