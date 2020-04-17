module Msg exposing (Msg(..))

import Domain.Effect as Effect exposing (Effect)

type Msg
    = SystemAppliedEffect Effect
