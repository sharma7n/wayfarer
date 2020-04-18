module Domain.Scene exposing
    ( Scene(..)
    , ambient
    , toString
    )

import Domain.Battle as Battle exposing (Battle)
import Domain.Dungeon as Dungeon exposing (Dungeon)
import Domain.Object as Object exposing (Object)


type Scene
    = Home
    | MapSelect
    | Dungeon Dungeon
    | Battle Battle Scene
    | BossBattle Battle
    | Shop (List Object) Scene
    | Inn Scene
    | GameOver


toString : Scene -> String
toString scene =
    case scene of
        Home ->
            "Home"

        MapSelect ->
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
        MapSelect ->
            Just Home

        Battle _ ambientScene ->
            Just ambientScene

        Shop _ ambientScene ->
            Just ambientScene

        Inn ambientScene ->
            Just ambientScene

        _ ->
            Nothing
