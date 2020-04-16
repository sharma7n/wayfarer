module Lib.Counter exposing
    ( Counter
    , get
    , modify
    , new
    )

import Dict exposing (Dict)


type Counter comparable
    = Counter (Dict comparable Int)


new : Counter comparable
new =
    Counter <|
        Dict.empty


modify : comparable -> Int -> Counter comparable -> Counter comparable
modify key delta (Counter data) =
    let
        newValue =
            data
                |> Dict.get key
                |> Maybe.withDefault 0
                |> (\v -> v + delta)
                |> max 0
    in
    Counter <|
        data
            |> Dict.insert key newValue


get : comparable -> Counter comparable -> Int
get key (Counter data) =
    data
        |> Dict.get key
        |> Maybe.withDefault 0
