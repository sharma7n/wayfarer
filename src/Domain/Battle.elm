module Domain.Battle exposing
    ( Battle
    , new
    , tick
    )

import Domain.Action as Action exposing (Action)
import Domain.Monster as Monster exposing (Monster)
import Effect.Battle as Effect exposing (Effect)
import Lib.Bounded as Bounded


type alias Battle =
    { actionPoints : Int
    , generatedBlock : Int
    , monster : Monster
    , actions : List Action
    , round : Int
    }


new : Monster -> Battle
new monster =
    { actionPoints = 3
    , generatedBlock = 0
    , monster = monster
    , actions =
        [ "attack", "defend", "wait" ]
            |> List.filterMap Action.getById
    , round = 1
    }


tick : Battle -> Battle
tick battle =
    { battle
        | actionPoints = 3
        , generatedBlock = 0
        , round = battle.round + 1
    }
