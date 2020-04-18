module Domain.Effect exposing (Effect(..))


type Effect
    = ChangeTime Int
    | ChangeHitPoints Int
