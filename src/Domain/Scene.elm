module Domain.Scene exposing (Scene(..))

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
