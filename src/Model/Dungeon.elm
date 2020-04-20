module Model.Dungeon exposing (modify)

import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Global as Global exposing (Global)
import Effect.Dungeon as Effect exposing (Effect)
import Lib.Bounded as Bounded
import Model exposing (Model)
import Msg exposing (Msg)


modify : Effect -> ( Global, Dungeon, Cmd Msg ) -> ( Global, Dungeon, Cmd Msg )
modify effect ( global, dungeon, cmd ) =
    case effect of
        Effect.RandomEncounter ->
            ( global
            , dungeon
            , cmd
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
