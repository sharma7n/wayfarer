module View.Ui exposing
    ( Choice
    , Ui
    , choice
    , context
    , description
    , header
    , image
    , info
    , label
    , layout
    , quantity
    , screen
    , stage
    )

import Domain.Effect as Effect exposing (Effect)
import Domain.Requirement as Requirement exposing (Requirement)
import Domain.Scene as Scene exposing (Scene)
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
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
    Element.el
        [ Element.Font.variant Element.Font.smallCaps
        ]
        (Element.text text)


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
image imagePath =
    Image imagePath


imageElement : Image -> Element msg
imageElement (Image imagePath) =
    Element.el
        [ Element.Border.width 1
        , Element.Background.color <| Element.rgb255 0 0 0
        , Element.width <| Element.px 320
        , Element.height <| Element.px 240
        ]
        Element.none


type Header
    = Header Scene


header : Scene -> Header
header scn =
    Header scn


headerElement : Header -> Element Msg
headerElement (Header scn) =
    Element.row
        [ Element.width Element.fill
        , Element.height <| Element.px 50
        , Element.Font.color <| Element.rgb255 255 255 255
        , Element.Background.color <| Element.rgb255 0 0 0
        , Element.padding 10
        , Element.Font.variant Element.Font.smallCaps
        , Element.Font.bold
        , Element.spacing 20
        ]
        [ backElement <| Scene.ambient scn
        , labelElement <| label <| Scene.toString scn
        ]


backElement : Maybe Scene -> Element Msg
backElement maybeScene =
    case maybeScene of
        Nothing ->
            Element.none

        Just scene ->
            Element.Input.button
                [ Element.Font.variant Element.Font.smallCaps
                ]
                { onPress =
                    Just <| Msg.UserSelectedScene scene
                , label =
                    labelElement <| label "ᐊ Back"
                }


type Info
    = Info Label Quantity


info : { label : Label, quantity : Quantity } -> Info
info o =
    Info o.label o.quantity


infoElement : Info -> Element msg
infoElement (Info lbl qty) =
    Element.row
        [ Element.width Element.fill
        , Element.spacing 10
        ]
        [ Element.el
            [ Element.width Element.fill
            ]
            (Element.el
                [ Element.alignRight
                , Element.Font.bold
                ]
                (labelElement lbl)
            )
        , Element.el
            [ Element.alignLeft
            , Element.width Element.fill
            ]
            (quantityElement qty)
        ]


type Context
    = Context (List Info)


context : List Info -> Context
context infoos =
    Context infoos


contextElement : Context -> Element msg
contextElement (Context infos) =
    Element.column
        [ Element.Background.color <| Element.rgb255 250 225 200
        , Element.alignTop
        , Element.width <| Element.px 250
        , Element.padding 10
        , Element.Border.width 1
        ]
        [ Element.column
            [ Element.height Element.fill
            , Element.width Element.fill
            , Element.Background.color <| Element.rgb255 255 255 255
            , Element.padding 10
            , Element.spacing 5
            , Element.Border.width 1
            ]
            (List.map infoElement infos)
        ]


type Stage
    = Stage Label Image Description


stage : { label : Label, image : Image, description : Description } -> Stage
stage o =
    Stage o.label o.image o.description


stageElement : Stage -> Element msg
stageElement (Stage lbl img desc) =
    Element.column
        [ Element.padding 10
        , Element.Background.color <| Element.rgb255 250 225 200
        , Element.centerX
        , Element.width <| Element.px 600
        , Element.height Element.fill
        , Element.Border.width 1
        ]
        [ Element.column
            [ Element.Border.width 1
            , Element.width Element.fill
            , Element.height Element.fill
            , Element.Background.color <| Element.rgb255 255 255 255
            , Element.padding 10
            , Element.spacing 10
            ]
            [ Element.el
                [ Element.Font.bold
                ]
                (labelElement lbl)
            , imageElement img
            , descriptionElement desc
            ]
        ]


type Choice
    = Choice Label Description (List Requirement) Msg


choice : { label : Label, description : Description, requirements : List Requirement, msg : Msg } -> Choice
choice o =
    Choice o.label o.description o.requirements o.msg


choiceElement : Choice -> Element Msg
choiceElement (Choice lbl desc requirements msg) =
    Element.Input.button
        [ Element.Background.color <| Element.rgb255 255 255 255
        , Element.Border.width 1
        , Element.padding 10
        ]
        { onPress =
            Just msg
        , label =
            Element.column
                [ Element.spacing 5
                ]
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
            , Element.Background.color <| Element.rgb255 150 100 50
            , Element.Font.family
                [ Element.Font.typeface "verdana"
                , Element.Font.sansSerif
                ]
            ]
            [ headerElement o.header
            , Element.row
                [ Element.width Element.fill
                , Element.height Element.fill
                , Element.padding 20
                ]
                [ contextElement o.context
                , Element.column
                    [ Element.width Element.fill
                    , Element.height Element.fill
                    , Element.spacing 10
                    ]
                    [ stageElement o.stage
                    , Element.wrappedRow
                        [ Element.padding 10
                        , Element.Background.color <| Element.rgb255 250 225 200
                        , Element.centerX
                        , Element.width <| Element.px 600
                        , Element.height <| Element.px 250
                        , Element.Border.width 1
                        ]
                        (List.map choiceElement o.choices)
                    ]
                ]
            ]
