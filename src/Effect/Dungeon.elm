module Effect.Dungeon exposing (Effect(..))


type Effect
    = ChangeSafety Int
    | ChangePath Int
