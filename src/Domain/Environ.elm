module Domain.Environ exposing
    ( Environ(..)
    , toString
    )


type Environ
    = Plains
    | Forest
    | Cave
    | Mountain
    | Ruins


toString : Environ -> String
toString environ =
    case environ of
        Plains ->
            "Plains"

        Forest ->
            "Forest"

        Cave ->
            "Cave"

        Mountain ->
            "Mountain"

        Ruins ->
            "Ruins"
