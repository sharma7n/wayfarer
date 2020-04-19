module Domain.Environ exposing
    ( Environ(..)
    , toString
    )

import Lib.Distribution as Distribution exposing (Distribution)
import Random

-- ELEMENTS: Fire, Ice, Water, Lightning, Wind, Earth, Dark, Light, Leaf, Moon, Law, Chaos, Prism
-- ENVIRONS: Plains, Forest, Cave, Mountain, Temple, Desert, Waterway
-- Fire: Cave, Mountain, Desert, Temple
-- Ice: Plains, Forest, Cave, Mountain, Temple, Desert, Waterway
-- Water: Plains, Forest, Cave, Mountain, Temple, Waterway
-- Lightning: Plains, Forest, Mountain, Desert, Waterway
-- Wind: Plains, Forest, Cave, Mountain, Temple, Desert, Waterway
-- Earth: Plains, Forest, Cave, Mountain, Temple, Desert
-- Dark:  

type Environ
    = Plains
    | Forest
    | Cave
    | Mountain
    | Ruins
    | Desert
    | Waterway


toString : Environ -> String
toString environ =
    case environ of
        Plains ->
            "Plains"

        Forest ->
            "Forest"

        Cave ->
            "Cave"

        Mountain ->
            "Mountain"

        Ruins ->
            "Ruins"
        
        Desert ->
            "Desert"
        
        Waterway ->
            "Waterway"

generator : Random.Generator Environ
generator =
    Distribution.random <|
        Distribution.new
            ( 1, Plains )
            [ ( 1, Forest )
            , ( 1, Cave )
            , ( 1, Mountain )
            , ( 1, Ruins)
            , ( 1, Desert )
            , ( 1, Waterway )
            ]