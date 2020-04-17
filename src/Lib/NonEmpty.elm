module Lib.NonEmpty exposing
    ( NonEmpty
    , append
    , head
    , new
    , tail
    , toList
    )


type NonEmpty a
    = NonEmpty a (List a)


new : a -> List a -> NonEmpty a
new x xs =
    NonEmpty x xs


append : a -> NonEmpty a -> NonEmpty a
append x (NonEmpty y ys) =
    NonEmpty x (y :: ys)


head : NonEmpty a -> a
head (NonEmpty x _) =
    x


tail : NonEmpty a -> List a
tail (NonEmpty _ xs) =
    xs


toList : NonEmpty a -> List a
toList (NonEmpty x xs) =
    x :: xs
