module Model.Global exposing
    ( runEffect
    , runRequirement
    , satisfiesRequirement
    )

import Domain.Global as Global exposing (Global)
import Effect.Global as Effect exposing (Effect)
import Lib.Bounded as Bounded
import Msg exposing (Msg)
import Requirement.Global as Requirement exposing (Requirement)


runEffect : Effect -> ( Global, Cmd Msg ) -> ( Global, Cmd Msg )
runEffect effect ( global, cmd ) =
    case effect of
        Effect.ChangeHitPoints hitPointDelta ->
            ( { global | hitPoints = global.hitPoints |> Bounded.addCapped global.maxHitPoints hitPointDelta }
            , cmd
            )

        Effect.ChangeGold goldDelta ->
            ( { global | gold = global.gold |> Bounded.add goldDelta }
            , cmd
            )


runRequirement : Requirement -> ( Global, Cmd Msg ) -> ( Global, Cmd Msg )
runRequirement requirement ( global, cmd ) =
    case requirement of
        Requirement.HitPointCost cost ->
            ( { global | hitPoints = global.hitPoints |> Bounded.subtract cost }
            , cmd
            )

        Requirement.GoldCost cost ->
            ( { global | gold = global.gold |> Bounded.subtract cost }
            , cmd
            )


satisfiesRequirement : Requirement -> Global -> Bool
satisfiesRequirement requirement global =
    case requirement of
        Requirement.HitPointCost cost ->
            global.hitPoints >= cost

        Requirement.GoldCost cost ->
            global.gold >= cost
