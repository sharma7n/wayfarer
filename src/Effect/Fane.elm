module Effect.Fane exposing
    ( Effect(..)
    , toString
    )


type Effect
    = SelectMap String


toString : Effect -> String
toString effect =
    case effect of
        SelectMap _ ->
            "Select Map"
