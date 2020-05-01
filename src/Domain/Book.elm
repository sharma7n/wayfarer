module Domain.Book exposing
    ( Book
    , Genre(..)
    , getById
    )

import Domain.Effect as Effect exposing (Effect)


type Genre
    = NonFiction
    | Horror
    | Mystery
    | Romance
    | Fantasy
    | Comedy


type alias Book =
    { id : String
    , title : String
    , description : String
    , author : String
    , genre : Genre
    , chapters : Int
    , pages : Int
    , effects : List Effect
    }


getById : String -> Maybe Book
getById id =
    case id of
        "wizenGulch" ->
            Just wizenGulch

        _ ->
            Nothing



-- BOOK OBJECTS


wizenGulch : Book
wizenGulch =
    { id = "wizenGulch"
    , title = "Wizen Gulch"
    , description = "A tale of gunpowder, gold, and goblins."
    , author = "D. M."
    , genre = Fantasy
    , chapters = 10
    , pages = 30
    , effects = []
    }
