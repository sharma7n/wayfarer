module View.Scene exposing (view)

import Domain.Battle as Battle exposing (Battle)
import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Event as Event exposing (Event)
import Domain.Global as Global exposing (Global)
import Domain.Map as Map exposing (Map)
import Domain.Object as Object exposing (Object)
import Domain.Scene as Scene exposing (Scene)
import Model exposing (Model)
import Msg exposing (Msg)
import View.Ui as Ui exposing (Ui)


view : Model -> Ui Msg
view model =
    case model.scene of
        Scene.Home ->
            viewHome model

        Scene.MapSelect ->
            viewMapSelect model

        Scene.Dungeon dungeon ->
            viewDungeon dungeon model

        Scene.Battle battle ambient ->
            viewBattle battle ambient model

        Scene.BossBattle battle ->
            viewBossBattle battle model

        Scene.Shop stock ambient ->
            viewShop stock ambient model

        Scene.Inn ambient ->
            viewInn ambient model

        Scene.GameOver ->
            viewGameOver model


viewHome : Model -> Ui Msg
viewHome model =
    Ui.screen
        { header =
            Ui.header model.scene
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "Time"
                    , quantity = Ui.quantity model.global.time
                    }
                , Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity model.global.hitPoints
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
            [ Ui.choice
                { label =
                    Ui.label "Explore"
                , description =
                    Ui.description ""
                , requirements =
                    []
                , msg =
                    Msg.UserSelectedScene Scene.MapSelect
                }
            , Ui.choice
                { label =
                    Ui.label "Shop"
                , description =
                    Ui.description ""
                , requirements =
                    []
                , msg =
                    Msg.UserSelectedScene <| Scene.Shop [] Scene.Home
                }
            , Ui.choice
                { label =
                    Ui.label "Inn"
                , description =
                    Ui.description ""
                , requirements =
                    []
                , msg =
                    Msg.UserSelectedScene <| Scene.Inn Scene.Home
                }
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
                    Ui.label "Stage"
                , image =
                    Ui.image "Image"
                , description =
                    Ui.description "Description"
                }
        , choices =
            List.map mapChoice model.global.maps
        }


mapChoice : Map -> Ui.Choice
mapChoice map =
    Ui.choice
        { label = Ui.label <| Map.toString map
        , description = Ui.description ""
        , requirements = []
        , msg =
            Msg.UserSelectedMap map
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
            List.map eventChoice dungeon.events
        }


eventChoice : Event -> Ui.Choice
eventChoice event =
    Ui.choice
        { label = Ui.label event.name
        , description = Ui.description event.description
        , requirements = event.requirements
        , msg =
            Msg.UserSelectedEvent event
        }


viewBattle : Battle -> Scene -> Model -> Ui Msg
viewBattle battle ambient model =
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


viewShop : List Object -> Scene -> Model -> Ui Msg
viewShop stock ambient model =
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


viewInn : Scene -> Model -> Ui Msg
viewInn ambient model =
    Ui.screen
        { header =
            Ui.header model.scene
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity model.global.hitPoints
                    }
                , Ui.info
                    { label = Ui.label "Gold"
                    , quantity = Ui.quantity model.global.gold
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
