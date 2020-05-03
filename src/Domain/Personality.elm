module Domain.Personality exposing (Profile)

-- cooperative/contrarian
-- stoic/emotive
-- bold/cautious
-- carefree/diligent


type alias Profile =
    { empathy : Int
    , daring : Int
    , discipline : Int
    , cooperation : Int
    , intuition : Int
    }
