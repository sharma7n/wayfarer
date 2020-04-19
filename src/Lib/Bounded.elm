module Lib.Bounded exposing
    ( add
    , addCapped
    )


add : Int -> Int -> Int
add delta base =
    max 0 (delta + base)


addCapped : Int -> Int -> Int -> Int
addCapped cap delta base =
    (delta + base)
        |> max 0
        |> min cap
