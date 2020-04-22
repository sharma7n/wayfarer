module Model.Dungeon exposing
    ( runEffect
    , runRequirement
    , satisfiesRequirement
    )

import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Event as Event exposing (Event)
import Domain.Global as Global exposing (Global)
import Domain.Monster as Monster exposing (Monster)
import Effect.Dungeon as Effect exposing (Effect)
import Lib.Bounded as Bounded
import Model exposing (Model)
import Msg exposing (Msg)
import Random
import Requirement.Dungeon as Requirement exposing (Requirement)


runEffect : Effect -> ( Global, Dungeon, Cmd Msg ) -> ( Global, Dungeon, Cmd Msg )
runEffect effect ( global, dungeon, cmd ) =
    case effect of
        Effect.RandomEncounter ->
            ( global
            , dungeon
            , Cmd.batch
                [ cmd
                , Random.generate Msg.SystemGotMonster (Monster.generator dungeon.map)
                ]
            )

        Effect.ChangeSafety safetyDelta ->
            ( global
            , { dungeon | safety = dungeon.safety |> Bounded.add safetyDelta }
            , cmd
            )

        Effect.ChangePath pathDelta ->
            ( global
            , { dungeon | path = dungeon.path |> Bounded.add pathDelta }
            , cmd
            )

        Effect.AppendEvents numberOfEvents ->
            let
                eventGeneratorCmds =
                    List.repeat numberOfEvents (Random.generate Msg.SystemGotEvent (Event.generator dungeon.map))

                newCmd =
                    Cmd.batch <| cmd :: eventGeneratorCmds
            in
            ( global
            , dungeon
            , newCmd
            )


runRequirement : Requirement -> ( Global, Dungeon, Cmd Msg ) -> ( Global, Dungeon, Cmd Msg )
runRequirement requirement ( global, dungeon, cmd ) =
    case requirement of
        Requirement.SafetyCost cost ->
            ( global
            , { dungeon | safety = dungeon.safety |> Bounded.subtract cost }
            , cmd
            )

        Requirement.PathCost cost ->
            ( global
            , { dungeon | path = dungeon.path |> Bounded.subtract cost }
            , cmd
            )


satisfiesRequirement : Requirement -> Dungeon -> Bool
satisfiesRequirement requirement dungeon =
    case requirement of
        Requirement.SafetyCost cost ->
            dungeon.safety >= cost

        Requirement.PathCost cost ->
            dungeon.path >= cost
