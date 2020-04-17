module App.Ui exposing
    ( Ui
    , layout
    , screen
    , label
    , description
    , image
    , header
    , context
    , stage
    )

import Domain.Requirement as Requirement exposing (Requirement)
import Domain.Effect as Effect exposing (Effect)
import Element exposing (Element)
import Element.Background
import Element.Input
import Element.Font
import Html exposing (Html)
import Msg exposing (Msg)

type Ui msg
    = Ui (Element msg)

layout : Ui msg -> Html msg
layout (Ui element) =
    Element.layout [] element

type Label
    = Label String

label : String -> Label
label text =
    Label text

labelElement : Label -> Element msg
labelElement (Label text) =
    Element.text text

type Description
    = Description String

description : String -> Description
description desc =
    Description desc

descriptionElement : Description -> Element msg
descriptionElement (Description desc) =
    Element.text desc

type Quantity
    = Quantity Int

quantity : Int -> Quantity
quantity qty =
    Quantity qty

quantityElement : Quantity -> Element msg
quantityElement (Quantity qty) =
    Element.text <| String.fromInt qty

type Image
    = Image String

image : String -> Image
image imagePath
    = Image imagePath

imageElement : Image -> Element msg
imageElement (Image imagePath) =
    Element.none

type Header
    = Header Label

header : Label -> Header
header lbl =
    Header lbl

headerElement : Header -> Element msg
headerElement (Header lbl) =
    Element.row
        [ Element.width Element.fill
        , Element.height <| Element.px 50
        , Element.Font.color <| Element.rgb255 255 255 255
        , Element.Background.color <| Element.rgb255 0 0 0
        ]
        [ labelElement lbl
        ]

type Info
    = Info Label Quantity

info : { label : Label, quantity : Quantity } -> Info
info o =
    Info o.label o.quantity

infoElement : Info -> Element msg
infoElement (Info lbl qty) =
    Element.row
        []
        [ labelElement lbl
        , quantityElement qty
        ]

type Context
    = Context (List Info)

context : List { label : Label, quantity : Quantity } -> Context
context infoos =
    Context <| List.map info infoos

contextElement : Context -> Element msg
contextElement (Context infos) =
    Element.column
        []
        (List.map infoElement infos)
type Stage
    = Stage Label Image Description

stage : { label : Label, image : Image, description : Description } -> Stage
stage o =
    Stage o.label o.image o.description

stageElement : Stage -> Element msg
stageElement (Stage lbl img desc) =
    Element.column
        []
        [ labelElement lbl
        , imageElement img
        , descriptionElement desc
        ]

type Choice
    = Choice Label Description (List Requirement) (List Effect)

choice : { label : Label, description : Description, requirements : List Requirement, effects : List Effect } -> Choice
choice o =
    Choice o.label o.description o.requirements o.effects

choiceElement : Choice -> Element Msg
choiceElement (Choice lbl desc requirements effects) =
    Element.Input.button
        []
        { onPress =
            case effects of
                [] ->
                    Nothing
                
                _ ->
                    Just <| Msg.SystemAppliedEffect (Effect.Batch effects)
        , label =
            Element.column
                []
                [ labelElement lbl
                , descriptionElement desc
                ]
        }

type alias Screen =
    { header : Header
    , context : Context
    , stage : Stage
    , choices : List Choice
    }

screen : Screen -> Ui Msg
screen o =
    Ui <|
        Element.column
            [ Element.width Element.fill
            , Element.height Element.fill
            ]
            [ headerElement o.header
            , contextElement o.context
            , stageElement o.stage
            , Element.wrappedRow
                []
                (List.map choiceElement o.choices)
            ]