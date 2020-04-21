module Effect.Dungeon exposing
    ( Effect(..)
    , toString
    )


type Effect
    = RandomEncounter
    | ChangeSafety Int
    | ChangePath Int
    | AppendEvents Int


toString : Effect -> String
toString effect =
    case effect of
        RandomEncounter ->
            "Encounter"

        ChangeSafety delta ->
            "Safety " ++ String.fromInt delta

        ChangePath delta ->
            "Path " ++ String.fromInt delta

        AppendEvents nb ->
            "Event " ++ String.fromInt nb
