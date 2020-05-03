module Lib.Nat exposing
    ( Nat
    , add
    , decoder
    , fromInt
    , unsafeFromInt
    )

import Json.Decode as D


type Nat
    = Nat Int


fromInt : Int -> Maybe Nat
fromInt i =
    if i >= 0 then
        Just (Nat i)

    else
        Nothing



-- UNSAFE: Must be passed in arg >= 0.
-- DEPRECATED: Replace all uses with fromInt or decoder.


unsafeFromInt : Int -> Nat
unsafeFromInt i =
    Nat i


decoder : D.Decoder Nat
decoder =
    D.int
        |> D.andThen
            (\i ->
                if i >= 0 then
                    D.succeed (Nat i)

                else
                    D.fail "Nat.decoder: argument less than 0."
            )


lift : (Int -> Int) -> Nat -> Nat
lift f (Nat x) =
    Nat <| f x


lift2 : (Int -> Int -> Int) -> Nat -> Nat -> Nat
lift2 f (Nat y) (Nat x) =
    Nat <| f y x


add : Nat -> Nat -> Nat
add =
    lift2 (\y -> \x -> y + x)
