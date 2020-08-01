module Main exposing (..)

import Browser
import Html
import Html.Events

type alias Model =
    { day : Int
    , maxTime : Int
    , time : Int
    , experience : Int
    , maxHitPoints : Int
    , hitPoints : Int
    , attack : Int
    , defense : Int
    , gold : Int
    , inventory : List String
    }

type Msg
    = Inn
    | Explore
    | SpringTrap
    | FightSquirrel
    | GainGold
    | GainPotion
    | UsePotion
    | SavePoint

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

-- INIT

init : flags -> ( Model, Cmd msg )
init _ =
    let
        initModel =
            { day = 1
            , maxTime = 3
            , time = 3
            , experience = 0
            , maxHitPoints = 8
            , hitPoints = 8
            , attack = 1
            , defense = 0
            , gold = 0
            , inventory = []
            }
    in   
    ( initModel, Cmd.none )

-- VIEW

view : Model -> Html.Html Msg
view model =
    Html.ul
        []
        [ Html.li [] [ Html.text <| "Day: " ++ String.fromInt model.day ]
        , Html.li [] [ Html.text <| "Time: " ++ String.fromInt model.time ++ " / " ++ String.fromInt model.maxTime ]
        , Html.li [] [ Html.text <| "EXP: " ++ String.fromInt model.experience ]
        , Html.li [] [ Html.text <| "HP: " ++ String.fromInt model.hitPoints ++ " / " ++ String.fromInt model.maxHitPoints ]
        , Html.li [] [ Html.text <| "ATK: " ++ String.fromInt model.attack ]
        , Html.li [] [ Html.text <| "DEF: " ++ String.fromInt model.defense ]
        , Html.li [] [ Html.text <| "Gold: " ++ String.fromInt model.gold ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Inventory: " ]
            , Html.ul 
                []
                ( List.map (\item -> Html.button [ Html.Events.onClick UsePotion ] [ Html.text item ]) model.inventory)
            ]
        , Html.button [ Html.Events.onClick Inn ] [ Html.text <| "Inn" ]
        , Html.button [ Html.Events.onClick Explore ] [ Html.text <| "Explore" ]
        , Html.button [ Html.Events.onClick SpringTrap ] [ Html.text <| "Spring Trap" ]
        , Html.button [ Html.Events.onClick FightSquirrel ] [ Html.text <| "Fight Squirrel" ]
        , Html.button [ Html.Events.onClick GainGold ] [ Html.text <| "Gain Gold" ]
        , Html.button [ Html.Events.onClick GainPotion ] [ Html.text <| "Gain Potion" ]
        , Html.button [ Html.Events.onClick SavePoint ] [ Html.text <| "Save Point" ]
        ]

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
    case msg of
        Inn ->
            updateInn model
        
        Explore ->
            updateExplore model
        
        SpringTrap ->
            updateSpringTrap model
        
        FightSquirrel ->
            updateFightSquirrel model
        
        GainGold ->
            updateGainGold model
        
        GainPotion ->
            updateGainPotion model
        
        UsePotion ->
            updateUsePotion model
        
        SavePoint ->
            updateSavePoint model

updateInn : Model -> ( Model, Cmd Msg )
updateInn model =
    let 
        newModel =
            { model
                | day = model.day + 1
                , time = model.maxTime
            }
    in
    ( newModel, Cmd.none )

updateExplore : Model -> ( Model, Cmd Msg )
updateExplore model =
    let 
        newModel =
            { model
                | time = max (model.time - 1) 0
            }
    in
    ( newModel, Cmd.none )

updateSpringTrap : Model -> ( Model, Cmd Msg )
updateSpringTrap model =
    let 
        newModel =
            { model
                | hitPoints = max (model.hitPoints - 1) 0
            }
    in
    ( newModel, Cmd.none )

updateFightSquirrel : Model -> ( Model, Cmd Msg )
updateFightSquirrel model =
    let
        damage = max (1 - model.defense) 0
        expGain = if model.attack >= 1 then 1 else 0
        goldGain = if model.attack >= 1 then 1 else 0
        newModel =
            { model
                | hitPoints = max (model.hitPoints - damage) 0
                , experience = model.experience + expGain
                , gold = model.gold + goldGain
            }
    in
    ( newModel, Cmd.none )

updateGainGold : Model -> ( Model, Cmd Msg )
updateGainGold model =
    let
        newModel =
            { model
                | gold = model.gold + 1
            }
    in
    ( newModel, Cmd.none )

updateGainPotion : Model -> ( Model, Cmd Msg )
updateGainPotion model =
    let
        newModel =
            { model
                | inventory = "potion" :: model.inventory
            }
    in
    ( newModel, Cmd.none )

updateUsePotion : Model -> ( Model, Cmd Msg )
updateUsePotion model =
    let
        newModel =
            { model
                | inventory = Maybe.withDefault [] (List.tail model.inventory)
                , hitPoints = min (model.hitPoints + 1) model.maxHitPoints
            }
    in
    ( newModel, Cmd.none )

updateSavePoint : Model -> ( Model, Cmd Msg )
updateSavePoint model =
    let
        hpGain = (model.maxHitPoints // 10) + 1
        newModel =
            { model
                | hitPoints = min (model.hitPoints + hpGain) model.maxHitPoints
            }
    in
    ( newModel, Cmd.none )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none