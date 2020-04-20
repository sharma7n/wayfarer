module Model.Battle exposing (modify)

import Domain.Battle as Battle exposing (Battle)
import Domain.Global as Global exposing (Global)
import Effect.Battle as Effect exposing (Effect)
import Lib.Bounded as Bounded
import Model exposing (Model)
import Msg exposing (Msg)


modify : Effect -> ( Global, Battle, Cmd Msg ) -> ( Global, Battle, Cmd Msg )
modify effect ( global, battle, cmd ) =
    case effect of
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
