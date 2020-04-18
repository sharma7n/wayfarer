module Msg exposing (Msg(..))

import Domain.Effect as Effect exposing (Effect)
import Domain.Scene as Scene exposing (Scene)


type Msg
    = SystemAppliedEffects (List Effect)
    | UserSelectedScene Scene
