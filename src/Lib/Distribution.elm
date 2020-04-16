module Lib.Distribution exposing
    ( Distribution
    , new
    , random
    )

import Lib.NonEmpty as NonEmpty exposing (NonEmpty)
import Random


type Distribution a
    = Distribution (NonEmpty ( Float, a ))


new : ( Float, a ) -> List ( Float, a ) -> Distribution a
new p ps =
    Distribution <|
        NonEmpty.new p ps


random : Distribution a -> Random.Generator a
random (Distribution l) =
    Random.weighted
        (NonEmpty.head l)
        (NonEmpty.tail l)
