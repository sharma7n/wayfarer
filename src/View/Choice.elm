module View.Choice exposing
    ( action
    , choices
    , event
    , explore
    , inn
    , map
    , shop
    )

import Domain.Action as Action exposing (Action)
import Domain.Computed as Computed exposing (Computed)
import Domain.Effect as Effect exposing (Effect)
import Domain.Event as Event exposing (Event)
import Domain.Global as Global exposing (Global)
import Domain.Map as Map exposing (Map)
import Domain.Object as Object exposing (Object)
import Domain.Requirement as Requirement exposing (Requirement)
import Domain.Scene as Scene exposing (Scene)
import Domain.Shop as Shop exposing (Shop)
import Effect.Global
import Msg exposing (Msg)
import Requirement.Global
import Requirement.Home
import View.Ui as Ui exposing (Ui)


explore : Ui.Choice
explore =
    { label = "Explore"
    , requirements = []
    , effects = []
    , msg = Msg.UserSelectedMapSelect
    , quantity = Nothing
    }


event : ( Event, Int ) -> Ui.Choice
event ( e, count ) =
    { label = e.name
    , requirements = e.requirements
    , effects = e.effects
    , msg = Msg.UserSelectedEvent e
    , quantity = Just count
    }


map : Map -> Ui.Choice
map m =
    { label = Map.toString m
    , requirements = []
    , effects = []
    , msg = Msg.UserSelectedMap m
    , quantity = Nothing
    }


shop : Shop -> Ui.Choice
shop s =
    { label = "Shop"
    , requirements = []
    , effects = []
    , msg = Msg.UserSelectedShop s
    , quantity = Nothing
    }


inn : Global -> Ui.Choice
inn global =
    let
        requirements =
            [ Requirement.Global <| Requirement.Global.GoldCost (global.maxHitPoints - global.hitPoints)
            , Requirement.Home <| Requirement.Home.TimeCost 3
            ]

        effects =
            [ Effect.Global <| Effect.Global.ChangeHitPoints (global.maxHitPoints - global.hitPoints)
            ]
    in
    { label = "Inn"
    , requirements = requirements
    , effects = effects
    , msg = Msg.Decorator requirements effects Msg.NoOp
    , quantity = Nothing
    }


action : Action -> Ui.Choice
action a =
    { label = a.name
    , requirements = a.requirements
    , effects = a.effects
    , msg = Msg.Decorator a.requirements a.effects Msg.NoOp
    , quantity = Nothing
    }


revive : Ui.Choice
revive =
    let
        reqs =
            [ Requirement.Global <| Requirement.Global.MaxHitPointCost 1
            ]

        effs =
            [ Effect.Global <| Effect.Global.ChangeHitPoints 1
            ]
    in
    { label = "Revive"
    , requirements = reqs
    , effects = effs
    , msg = Msg.Decorator reqs effs Msg.UserSelectedRevive
    , quantity = Nothing
    }


reincarnate : Ui.Choice
reincarnate =
    let
        reqs =
            []

        effs =
            []
    in
    { label = "Reincarnate"
    , requirements = reqs
    , effects = effs
    , msg = Msg.Decorator reqs effs Msg.UserSelectedReincarnate
    , quantity = Nothing
    }


choices : Computed -> List Ui.Choice -> List Ui.Choice
choices computed ccs =
    if computed.isDead then
        [ revive
        , reincarnate
        ]

    else
        ccs
