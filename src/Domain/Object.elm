module Domain.Object exposing
    ( Object(..)
    , cost
    , getById
    , name
    )

import Domain.Equipment as Equipment exposing (Equipment)
import Domain.Item as Item exposing (Item)


type Object
    = ItemObject Item
    | EquipmentObject Equipment


type alias Cata a =
    { item : Item -> a
    , equipment : Equipment -> a
    }


cata : Cata a -> Object -> a
cata f object =
    case object of
        ItemObject item ->
            f.item item

        EquipmentObject equipment ->
            f.equipment equipment


name : Object -> String
name object =
    object
        |> cata
            { item = .name
            , equipment = .name
            }


cost : Object -> Int
cost object =
    object
        |> cata
            { item = .cost
            , equipment = .cost
            }


getById : ( String, String ) -> Maybe Object
getById ( objectTypeId, objectId ) =
    case objectTypeId of
        "item" ->
            Item.getById objectId
                |> Maybe.map ItemObject

        "equipment" ->
            Equipment.getById objectId
                |> Maybe.map EquipmentObject

        _ ->
            Nothing
