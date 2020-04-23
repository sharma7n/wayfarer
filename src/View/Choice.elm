module View.Choice exposing
    ( event
    , explore
    , inn
    , map
    , shop
    )

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
    { label = "Inn"
    , requirements =
        [ Requirement.Global <| Requirement.Global.GoldCost (global.maxHitPoints - global.hitPoints)
        , Requirement.Home <| Requirement.Home.TimeCost 3
        ]
    , effects =
        [ Effect.Global <| Effect.Global.ChangeHitPoints (global.maxHitPoints - global.hitPoints)
        ]
    , msg =
        Msg.SystemAppliedEffects
            [ Effect.Global <| Effect.Global.ChangeHitPoints (global.maxHitPoints - global.hitPoints)
            ]
    }