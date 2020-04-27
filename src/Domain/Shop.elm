module Domain.Shop exposing (Shop)

import Domain.Object as Object exposing (Object)


type alias Shop =
    { name : String
    , stock : List Object
    }
