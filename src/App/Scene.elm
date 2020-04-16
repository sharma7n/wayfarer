module App.Scene exposing (view)

import Domain.Battle as Battle exposing (Battle)
import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Global as Global exposing (Global)
import Domain.Object as Object exposing (Object)
import Domain.Scene as Scene exposing (Scene)
import Lib.Ui as Ui exposing (Ui)


view : Scene -> Global -> Ui msg
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


viewHome : Global -> Ui msg
viewHome global =
    Ui.none


viewMapSelect : Global -> Ui msg
viewMapSelect global =
    Ui.none


viewDungeon : Dungeon -> Global -> Ui msg
viewDungeon dungeon global =
    Ui.none


viewBattle : Battle -> Scene -> Global -> Ui msg
viewBattle battle ambient global =
    Ui.none


viewBossBattle : Battle -> Global -> Ui msg
viewBossBattle battle global =
    Ui.none


viewShop : List Object -> Scene -> Global -> Ui msg
viewShop stock ambient global =
    Ui.none


viewInn : Scene -> Global -> Ui msg
viewInn ambient global =
    Ui.none


viewGameOver : Global -> Ui msg
viewGameOver global =
    Ui.none
