module Effect.Dungeon exposing (Effect(..))


type Effect
    = RandomEncounter
    | ChangeSafety Int
    | ChangePath Int
