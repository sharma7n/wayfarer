module View.Scene exposing (view)

import Domain.Battle as Battle exposing (Battle)
import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Effect as Effect exposing (Effect)
import Domain.Event as Event exposing (Event)
import Domain.Global as Global exposing (Global)
import Domain.Home as Home exposing (Home)
import Domain.Map as Map exposing (Map)
import Domain.Object as Object exposing (Object)
import Domain.Requirement as Requirement exposing (Requirement)
import Domain.Scene as Scene exposing (Scene)
import Domain.Shop as Shop exposing (Shop)
import Effect.Global
import Effect.Home
import Model exposing (Model)
import Msg exposing (Msg)
import Requirement.Global
import Requirement.Home
import View.Choice
import View.Ui as Ui exposing (Ui)


view : Model -> Ui Msg
view model =
    case model.scene of
        Scene.Home home ->
            viewHome home model

        Scene.MapSelect _ ->
            viewMapSelect model

        Scene.Dungeon dungeon ->
            viewDungeon dungeon model

        Scene.Battle battle ambient ->
            viewBattle battle ambient model

        Scene.BossBattle battle ->
            viewBossBattle battle model

        Scene.Shop stock ambient ->
            viewShop stock ambient model

        Scene.GameOver ->
            viewGameOver model


viewHome : Home -> Model -> Ui Msg
viewHome home model =
    Ui.screen
        { header =
            Ui.header model.scene
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "Time"
                    , quantity = Ui.quantity home.time
                    }
                , Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.ratio model.global.hitPoints model.global.maxHitPoints
                    }
                ]
        , stage =
            Ui.stage
                { label =
                    Ui.label "World Map"
                , image =
                    Ui.image "Image"
                , description =
                    Ui.description "Description"
                }
        , choices =
            [ View.Choice.explore
            , View.Choice.shop { name = "Main Shop", stock = [] }
            , View.Choice.inn model.global
            ]
        }


viewMapSelect : Model -> Ui Msg
viewMapSelect model =
    Ui.screen
        { header =
            Ui.header model.scene
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity model.global.hitPoints
                    }
                ]
        , stage =
            Ui.stage
                { label =
                    Ui.label "Ancient Fane"
                , image =
                    Ui.image "Image"
                , description =
                    Ui.description "Description"
                }
        , choices =
            List.map View.Choice.map model.global.maps
        }


viewDungeon : Dungeon -> Model -> Ui Msg
viewDungeon dungeon model =
    let
        stage =
            case dungeon.selectedEvent of
                Nothing ->
                    { label = Ui.label "Entrance"
                    , image = Ui.image "Image"
                    , description = Ui.description "Description"
                    }

                Just event ->
                    { label = Ui.label event.name
                    , image = Ui.image event.image
                    , description = Ui.description event.description
                    }
    in
    Ui.screen
        { header =
            Ui.header model.scene
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "Safety"
                    , quantity = Ui.quantity dungeon.safety
                    }
                , Ui.info
                    { label = Ui.label "Path"
                    , quantity = Ui.quantity dungeon.path
                    }
                , Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity model.global.hitPoints
                    }
                ]
        , stage = Ui.stage stage
        , choices =
            List.map View.Choice.event dungeon.events
        }


viewBattle : Battle -> Scene -> Model -> Ui Msg
viewBattle battle ambient model =
    Ui.screen
        { header =
            Ui.header ambient
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity model.global.hitPoints
                    }
                ]
        , stage =
            Ui.stage
                { label =
                    Ui.label <| battle.monster.name
                , image =
                    Ui.image "Image"
                , description =
                    Ui.description "Description"
                }
        , choices =
            []
        }


viewBossBattle : Battle -> Model -> Ui Msg
viewBossBattle battle model =
    Ui.screen
        { header =
            Ui.header model.scene
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity model.global.hitPoints
                    }
                ]
        , stage =
            Ui.stage
                { label =
                    Ui.label "Stage"
                , image =
                    Ui.image "Image"
                , description =
                    Ui.description "Description"
                }
        , choices =
            []
        }


viewShop : Shop -> Scene -> Model -> Ui Msg
viewShop shop ambient model =
    Ui.screen
        { header =
            Ui.header model.scene
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity model.global.hitPoints
                    }
                ]
        , stage =
            Ui.stage
                { label =
                    Ui.label shop.name
                , image =
                    Ui.image "Image"
                , description =
                    Ui.description "Description"
                }
        , choices =
            []
        }


viewGameOver : Model -> Ui Msg
viewGameOver model =
    Ui.screen
        { header =
            Ui.header model.scene
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity model.global.hitPoints
                    }
                ]
        , stage =
            Ui.stage
                { label =
                    Ui.label "Stage"
                , image =
                    Ui.image "Image"
                , description =
                    Ui.description "Description"
                }
        , choices =
            []
        }
