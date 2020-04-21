module Model.Global exposing (modify)

import Domain.Global as Global exposing (Global)
import Effect.Global as Effect exposing (Effect)
import Lib.Bounded as Bounded
import Msg exposing (Msg)


modify : Effect -> ( Global, Cmd Msg ) -> ( Global, Cmd Msg )
modify effect ( global, cmd ) =
    case effect of
        Effect.ChangeHitPoints hitPointDelta ->
            ( { global | hitPoints = global.hitPoints |> Bounded.addCapped global.maxHitPoints hitPointDelta }
            , cmd
            )

        Effect.ChangeGold goldDelta ->
            ( { global | gold = global.gold |> Bounded.add goldDelta }
            , cmd
            )
