module Domain.Monster exposing
    ( Monster
    , generator
    , getById
    )

import Domain.Behavior as Behavior exposing (Behavior)
import Domain.Environ as Environ exposing (Environ)
import Domain.Map as Map exposing (Map)
import Lib.Distribution as Distribution exposing (Distribution)
import Random


type alias Monster =
    { id : String
    , name : String
    , frequency : Float
    , environs : List Environ
    , hitPoints : Int
    , behaviors : Distribution Behavior
    }


getById : String -> Maybe Monster
getById id =
    case id of
        "slime" ->
            Just slime

        _ ->
            Nothing


all : List Monster
all =
    [ slime
    ]


generator : Map -> Random.Generator Monster
generator map =
    let
        validMonsters =
            all
                |> List.filter (\m -> List.member map.environ m.environs)
                |> List.map (\m -> ( m.frequency, m ))
    in
    case validMonsters of
        m :: ms ->
            Distribution.random <| Distribution.new m ms

        [] ->
            Random.constant missingno



-- MONSTER OBJECTS


missingno : Monster
missingno =
    { id = "missingno"
    , name = "Missingno"
    , frequency = 0.0
    , environs = []
    , hitPoints = 1
    , behaviors =
        Distribution.new
            ( 1, Behavior.DoNothing )
            []
    }


slime : Monster
slime =
    { id = "slime"
    , name = "Slime"
    , frequency = 1.0
    , environs = Environ.all
    , hitPoints = 5
    , behaviors =
        Distribution.new
            ( 1, Behavior.Attack )
            []
    }
