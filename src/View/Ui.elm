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
    , ratio
    , screen
    , stage
    )

import Domain.Choice
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
    = Scalar Int
    | Ratio Int Int


quantity : Int -> Quantity
quantity qty =
    Scalar qty


ratio : Int -> Int -> Quantity
ratio current max_ =
    Ratio current max_


quantityElement : Quantity -> Element msg
quantityElement qty =
    case qty of
        Scalar sc ->
            Element.text <| String.fromInt sc

        Ratio curr max_ ->
            let
                color =
                    if Basics.toFloat curr <= (0.3 * Basics.toFloat max_) then
                        Element.rgb255 150 0 0

                    else if Basics.toFloat curr <= (0.6 * Basics.toFloat max_) then
                        Element.rgb255 250 175 75

                    else
                        Element.rgb255 50 100 0
            in
            Element.el
                [ Element.Font.color color
                ]
                (Element.text <| String.fromInt curr ++ " / " ++ String.fromInt max_)


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
    let
        headerLabel =
            case Scene.ambient scn of
                Just scene ->
                    backElement scene

                Nothing ->
                    labelElement <| label <| Scene.toString scn
    in
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
        [ headerLabel
        ]


backElement : Scene -> Element Msg
backElement scene =
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
            , Element.el
                [ Element.centerX
                ]
                (imageElement img)
            , descriptionElement desc
            ]
        ]


type Choice
    = Choice Label (List Requirement) (List Effect) Msg


choice : { label : Label, requirements : List Requirement, effects : List Effect, msg : Msg } -> Choice
choice o =
    Choice o.label o.requirements o.effects o.msg


choiceAdapter : Domain.Choice.Choice -> Choice
choiceAdapter domainChoice =
    choice
        { label = label domainChoice.label
        , requirements = domainChoice.requirements
        , effects = domainChoice.effects
        , msg = Msg.UserSelectedChoice domainChoice
        }


choiceElement : Choice -> Element Msg
choiceElement (Choice lbl requirements effects msg) =
    Element.Input.button
        [ Element.Background.color <| Element.rgb255 255 255 255
        , Element.Border.width 1
        , Element.padding 10
        , Element.width Element.fill
        ]
        { onPress =
            Just msg
        , label =
            Element.column
                []
                [ labelElement lbl
                , Element.row
                    [ Element.spacing 5
                    ]
                    (List.map (Requirement.toString >> Element.text) requirements)
                , Element.row
                    [ Element.spacing 5
                    ]
                    (List.map (Effect.toString >> Element.text) effects)
                ]
        }


type alias Screen =
    { header : Header
    , context : Context
    , stage : Stage
    , choices : List Domain.Choice.Choice
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
                    ]
                , Element.column
                    [ Element.padding 10
                    , Element.Background.color <| Element.rgb255 250 225 200
                    , Element.centerX
                    , Element.width <| Element.px 300
                    , Element.Border.width 1
                    , Element.alignTop
                    , Element.spacing 10
                    ]
                    (List.map (choiceAdapter >> choiceElement) o.choices)
                ]
            ]
