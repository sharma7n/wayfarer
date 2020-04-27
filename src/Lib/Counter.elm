module Lib.Counter exposing
    ( Counter
    , decrement
    , fromList
    , get
    , increment
    , insert
    , new
    , remove
    , toList
    )

import Dict exposing (Dict)
import Lib.Bounded as Bounded


type Counter a
    = Counter (Data a)


type alias Data a =
    { toKey : a -> String
    , fromKey : String -> Maybe a
    , counts : Dict String Int
    }


new : (a -> String) -> (String -> Maybe a) -> Counter a
new toKey fromKey =
    Counter <|
        { toKey = toKey
        , fromKey = fromKey
        , counts = Dict.empty
        }


insert : a -> Counter a -> Counter a
insert item counter =
    counter
        |> increment item 1


remove : a -> Counter a -> Counter a
remove item counter =
    counter
        |> decrement item 1


modify : a -> (Int -> Int) -> Counter a -> Counter a
modify item f (Counter data) =
    let
        existingValue =
            data.counts
                |> Dict.get (data.toKey item)
                |> Maybe.withDefault 0

        newCounts =
            data.counts
                |> Dict.insert (data.toKey item) (f existingValue)
    in
    Counter <|
        { data
            | counts = newCounts
        }


increment : a -> Int -> Counter a -> Counter a
increment item n counter =
    counter
        |> modify item (Bounded.add n)


decrement : a -> Int -> Counter a -> Counter a
decrement item n counter =
    counter
        |> modify item (Bounded.subtract n)


get : a -> Counter a -> Int
get item (Counter data) =
    data.counts
        |> Dict.get (data.toKey item)
        |> Maybe.withDefault 0


fromList : (a -> String) -> (String -> Maybe a) -> List a -> Counter a
fromList toKey fromKey items =
    items
        |> List.foldr insert (new toKey fromKey)


toList : Counter a -> List ( a, Int )
toList (Counter data) =
    data.counts
        |> Dict.toList
        |> List.filter (\( _, count ) -> count > 0)
        |> List.filterMap
            (\( k, count ) ->
                data.fromKey k
                    |> Maybe.map (\v -> ( v, count ))
            )
