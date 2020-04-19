module Effect.Battle exposing (Effect(..))


type Effect
    = ChangeActionPoints Int
    | ChangeGeneratedBlock Int
    | ChangeMonsterHitPoints Int
