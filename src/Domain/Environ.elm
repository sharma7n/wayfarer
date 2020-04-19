module Domain.Environ exposing
    ( Environ(..)
    , toString
    )

import Lib.Distribution as Distribution exposing (Distribution)
import Random



-- ELEMENTS: Fire, Ice, Water, Lightning, Wind, Earth, Dark, Light, Leaf, Poison, Moon, Law, Chaos, Prism, Sun, Moon, Star
-- ENVIRONS: Plains, Forest, Cave, Mountain, Temple, Desert, Waterway
-- MOODS/THEMES: Beginning, Reflection, Sorrow,
-- Plains: Magma Crater (Fire), Snow Plains (Ice), Lake/Pond/Bayou (Water), Storm Plains (Lightning),
--  Windy Plains (Wind), Rocky Crater (Earth), Garden (Leaf), Swamp (Poison), Moonlit Plains (Moon),
--  Sunny Plains (Sun), Starry Plains (Star)
-- Forest: Burning Forest (Fire), Snow Forest (Ice), Rainforest/Jungle (Water), Rock Forest (Earth),
--  Dark Forest (Dark), Sacred Forest (Light), Woodsy Forest (Forest)
-- Cave:
-- Mountain:
-- Temple:
-- Desert:
-- Waterway:


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
            , ( 1, Ruins )
            , ( 1, Desert )
            , ( 1, Waterway )
            ]
