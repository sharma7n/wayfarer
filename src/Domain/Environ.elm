module Domain.Environ exposing
    ( Environ(..)
    , all
    , toString
    )

import Lib.Distribution as Distribution exposing (Distribution)
import Random


type Environ
    = Plains
    | Forest
    | Cave
    | Mountain
    | Temple
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

        Temple ->
            "Temple"

        Waterway ->
            "Waterway"


all : List Environ
all =
    [ Plains
    , Forest
    , Cave
    , Mountain
    , Temple
    , Waterway
    ]


generator : Random.Generator Environ
generator =
    Distribution.random <|
        Distribution.new
            ( 1, Plains )
            [ ( 1, Forest )
            , ( 1, Cave )
            , ( 1, Mountain )
            , ( 1, Temple )
            , ( 1, Waterway )
            ]
