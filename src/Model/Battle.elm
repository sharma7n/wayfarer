module Model.Battle exposing
    ( runEffect
    , runRequirement
    , satisfiesRequirement
    )

import Domain.Battle as Battle exposing (Battle)
import Domain.Global as Global exposing (Global)
import Effect.Battle as Effect exposing (Effect)
import Lib.Bounded as Bounded
import Model exposing (Model)
import Msg exposing (Msg)
import Requirement.Battle as Requirement exposing (Requirement)


runEffect : Effect -> ( Global, Battle, Cmd Msg ) -> ( Global, Battle, Cmd Msg )
runEffect effect ( global, battle, cmd ) =
    case effect of
        Effect.EndTurn ->
            ( global
            , battle |> Battle.tick
            , cmd
            )

        Effect.ChangeActionPoints actionPointDelta ->
            ( global
            , { battle | actionPoints = battle.actionPoints |> Bounded.add actionPointDelta }
            , cmd
            )

        Effect.ChangeGeneratedBlock generatedBlockDelta ->
            ( global
            , { battle | generatedBlock = battle.generatedBlock |> Bounded.add generatedBlockDelta }
            , cmd
            )

        Effect.ChangeMonsterHitPoints hitPointDelta ->
            let
                monster =
                    battle.monster

                newMonster =
                    { monster | hitPoints = monster.hitPoints |> Bounded.add hitPointDelta }
            in
            ( global
            , { battle | monster = newMonster }
            , cmd
            )

        Effect.DealDamage damage ->
            let
                monster =
                    battle.monster

                newMonster =
                    { monster | hitPoints = monster.hitPoints |> Bounded.subtract damage }
            in
            ( global
            , { battle | monster = newMonster }
            , cmd
            )


runRequirement : Requirement -> ( Global, Battle, Cmd Msg ) -> ( Global, Battle, Cmd Msg )
runRequirement requirement ( global, battle, cmd ) =
    case requirement of
        Requirement.ActionPointCost cost ->
            ( global
            , { battle | actionPoints = battle.actionPoints |> Bounded.subtract cost }
            , cmd
            )


satisfiesRequirement : Requirement -> Battle -> Bool
satisfiesRequirement requirement battle =
    case requirement of
        Requirement.ActionPointCost cost ->
            battle.actionPoints >= cost
