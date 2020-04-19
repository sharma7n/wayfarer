module Domain.Scene exposing
    ( Scene(..)
    , ambient
    , toString
    )

import Domain.Battle as Battle exposing (Battle)
import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Home as Home exposing (Home)
import Domain.Object as Object exposing (Object)


type Scene
    = Home Home
    | MapSelect Scene
    | Dungeon Dungeon
    | Battle Battle Scene
    | BossBattle Battle
    | Shop (List Object) Scene
    | Inn Scene
    | GameOver


toString : Scene -> String
toString scene =
    case scene of
        Home _ ->
            "Home"

        MapSelect _ ->
            "Ancient Fame"

        Dungeon _ ->
            "Dungeon"

        Battle _ _ ->
            "Battle"

        BossBattle _ ->
            "Boss Battle"

        Shop _ _ ->
            "Shop"

        Inn _ ->
            "Inn"

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

        Inn ambientScene ->
            Just ambientScene

        _ ->
            Nothing
