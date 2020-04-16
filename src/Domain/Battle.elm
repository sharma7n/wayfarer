module Domain.Battle exposing (Battle)

import Domain.Monster as Monster exposing (Monster)


type alias Battle =
    { actionPoints : Int
    , generatedBlock : Int
    , monster : Monster
    }
