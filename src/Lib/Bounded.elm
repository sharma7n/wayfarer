module Lib.Bounded exposing
    ( add
    , addCapped
    , capBy
    , subtract
    )


add : Int -> Int -> Int
add delta base =
    max 0 (delta + base)


addCapped : Int -> Int -> Int -> Int
addCapped cap delta base =
    (delta + base)
        |> max 0
        |> min cap


subtract : Int -> Int -> Int
subtract delta base =
    max 0 (base - delta)


capBy : Int -> Int -> Int
capBy cap quantity =
    min quantity cap
