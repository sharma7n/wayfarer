module Domain.Effect exposing (Effect(..))


type Effect
    = Batch (List Effect)
    | Other
