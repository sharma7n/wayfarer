module Model.Home exposing (modify)

import Domain.Global as Global exposing (Global)
import Domain.Home as Home exposing (Home)
import Effect.Home as Effect exposing (Effect)
import Lib.Bounded as Bounded
import Model exposing (Model)
import Msg exposing (Msg)


modify : Effect -> ( Global, Home, Cmd Msg ) -> ( Global, Home, Cmd Msg )
modify effect ( global, home, cmd ) =
    case effect of
        Effect.ChangeTime timeDelta ->
            ( global
            , { home | time = home.time |> Bounded.add timeDelta }
            , cmd
            )
