module App.Scene exposing (view)

import App.Ui as Ui exposing (Ui)
import Domain.Battle as Battle exposing (Battle)
import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Global as Global exposing (Global)
import Domain.Object as Object exposing (Object)
import Domain.Scene as Scene exposing (Scene)
import Msg exposing (Msg)


view : Scene -> Global -> Ui Msg
view scene global =
    case scene of
        Scene.Home ->
            viewHome global

        Scene.MapSelect ->
            viewMapSelect global

        Scene.Dungeon dungeon ->
            viewDungeon dungeon global

        Scene.Battle battle ambient ->
            viewBattle battle ambient global

        Scene.BossBattle battle ->
            viewBossBattle battle global

        Scene.Shop stock ambient ->
            viewShop stock ambient global

        Scene.Inn ambient ->
            viewInn ambient global

        Scene.GameOver ->
            viewGameOver global


viewHome : Global -> Ui Msg
viewHome global =
    Ui.screen
        { header =
            Ui.header <| Ui.label "Home"
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "Time"
                    , quantity = Ui.quantity global.time
                    }
                , Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity global.hitPoints
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
            [ Ui.choice
                { label =
                    Ui.label "Action"
                , description =
                    Ui.description "Action Description"
                , requirements =
                    []
                , effects =
                    []
                }
            ]
        }


viewMapSelect : Global -> Ui Msg
viewMapSelect global =
    Ui.screen
        { header =
            Ui.header <| Ui.label "Home"
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity 10
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


viewDungeon : Dungeon -> Global -> Ui Msg
viewDungeon dungeon global =
    Ui.screen
        { header =
            Ui.header <| Ui.label "Home"
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity 10
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


viewBattle : Battle -> Scene -> Global -> Ui Msg
viewBattle battle ambient global =
    Ui.screen
        { header =
            Ui.header <| Ui.label "Home"
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity 10
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


viewBossBattle : Battle -> Global -> Ui Msg
viewBossBattle battle global =
    Ui.screen
        { header =
            Ui.header <| Ui.label "Home"
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity 10
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


viewShop : List Object -> Scene -> Global -> Ui Msg
viewShop stock ambient global =
    Ui.screen
        { header =
            Ui.header <| Ui.label "Home"
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity 10
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


viewInn : Scene -> Global -> Ui Msg
viewInn ambient global =
    Ui.screen
        { header =
            Ui.header <| Ui.label "Home"
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity 10
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


viewGameOver : Global -> Ui Msg
viewGameOver global =
    Ui.screen
        { header =
            Ui.header <| Ui.label "Home"
        , context =
            Ui.context
                [ Ui.info
                    { label = Ui.label "HP"
                    , quantity = Ui.quantity 10
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
