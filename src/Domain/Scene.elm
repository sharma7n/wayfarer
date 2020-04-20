module Domain.Scene exposing
    ( Scene(..)
    , ambient
    , toString
    )

import Domain.Battle as Battle exposing (Battle)
import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Home as Home exposing (Home)
import Domain.Map as Map exposing (Map)
import Domain.Object as Object exposing (Object)


type Scene
    = Home Home
    | MapSelect Scene
    | Dungeon Dungeon
    | Battle Battle Scene
    | BossBattle Battle
    | Shop (List Object) Scene
    | GameOver


toString : Scene -> String
toString scene =
    case scene of
        Home _ ->
            "Home"

        MapSelect _ ->
            "Ancient Fame"

        Dungeon dungeon ->
            "Dungeon: " ++ Map.toString dungeon.map

        Battle _ _ ->
            "Battle"

        BossBattle _ ->
            "Boss Battle"

        Shop _ _ ->
            "Shop"

        GameOver ->
            "Game Over"


ambient : Scene -> Maybe Scene
ambient scene =
    case scene of
        MapSelect ambientScene ->
            Just ambientScene

        Battle _ ambientScene ->
            Just ambientScene

        Shop _ ambientScene ->
            Just ambientScene

        _ ->
            Nothing
