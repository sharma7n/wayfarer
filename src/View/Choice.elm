module View.Choice exposing
    ( action
    , event
    , explore
    , inn
    , map
    , shop
    )

import Domain.Action as Action exposing (Action)
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
    }


event : Event -> Ui.Choice
event e =
    { label = e.name
    , requirements = e.requirements
    , effects = e.effects
    , msg = Msg.UserSelectedEvent e
    }


map : Map -> Ui.Choice
map m =
    { label = Map.toString m
    , requirements = []
    , effects = []
    , msg = Msg.UserSelectedMap m
    }


shop : Shop -> Ui.Choice
shop s =
    { label = "Shop"
    , requirements = []
    , effects = []
    , msg = Msg.UserSelectedShop s
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
    }


action : Action -> Ui.Choice
action a =
    { label = a.name
    , requirements = a.requirements
    , effects = a.effects
    , msg = Msg.Decorator a.requirements a.effects Msg.NoOp
    }
