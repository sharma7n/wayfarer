module Domain.Battle exposing
    ( Battle
    , modify
    )

import Domain.Monster as Monster exposing (Monster)
import Effect.Battle as Effect exposing (Effect)
import Lib.Bounded as Bounded


type alias Battle =
    { actionPoints : Int
    , generatedBlock : Int
    , monster : Monster
    }


modify : Effect -> Battle -> Battle
modify effect battle =
    case effect of
        Effect.ChangeActionPoints actionPointDelta ->
            { battle | actionPoints = battle.actionPoints |> Bounded.add actionPointDelta }

        Effect.ChangeGeneratedBlock generatedBlockDelta ->
            { battle | generatedBlock = battle.generatedBlock |> Bounded.add generatedBlockDelta }

        Effect.ChangeMonsterHitPoints monsterHitPointDelta ->
            let
                monster =
                    battle.monster

                newMonster =
                    { monster | hitPoints = monster.hitPoints |> Bounded.add monsterHitPointDelta }
            in
            { battle | monster = newMonster }
