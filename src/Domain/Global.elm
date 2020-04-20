module Domain.Global exposing
    ( Global
    , init
    )

import Domain.Environ as Environ exposing (Environ)
import Domain.Equipment as Equipment exposing (Equipment)
import Domain.Item as Item exposing (Item)
import Domain.Map as Map exposing (Map)
import Domain.Skill as Skill exposing (Skill)
import Effect.Global as Effect exposing (Effect)
import Lib.Bounded as Bounded


type alias Global =
    { hitPoints : Int
    , gold : Int
    , maps : List Map
    , items : List Item
    , equipment : List Equipment
    , skills : List Skill
    }


init : Global
init =
    { hitPoints = 10
    , gold = 0
    , maps =
        [ { hash = "beginning", environ = Environ.Plains, level = 1 }
        ]
    , items = []
    , equipment = []
    , skills = []
    }
