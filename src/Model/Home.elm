module Model.Home exposing
    ( runEffect
    , runRequirement
    , satisfiesRequirement
    )

import Domain.Global as Global exposing (Global)
import Domain.Home as Home exposing (Home)
import Domain.Scene as Scene exposing (Scene)
import Effect.Home as Effect exposing (Effect)
import Lib.Bounded as Bounded
import Model exposing (Model)
import Msg exposing (Msg)
import Random
import Requirement.Home as Requirement exposing (Requirement)


runEffect : Effect -> ( Global, Home, Cmd Msg ) -> ( Global, Home, Cmd Msg )
runEffect effect ( global, home, cmd ) =
    case effect of
        Effect.Fane ->
            ( global
            , home
            , Cmd.batch [ cmd, Random.generate Msg.UserSelectedScene (Random.constant <| Scene.MapSelect (Scene.Home home)) ]
            )

        Effect.ChangeTime timeDelta ->
            ( global
            , { home | time = home.time |> Bounded.add timeDelta }
            , cmd
            )


runRequirement : Requirement -> ( Global, Home, Cmd Msg ) -> ( Global, Home, Cmd Msg )
runRequirement requirement ( global, home, cmd ) =
    case requirement of
        Requirement.TimeCost cost ->
            ( global
            , { home | time = home.time |> Bounded.subtract cost }
            , cmd
            )


satisfiesRequirement : Requirement -> Home -> Bool
satisfiesRequirement requirement home =
    case requirement of
        Requirement.TimeCost cost ->
            home.time >= cost
