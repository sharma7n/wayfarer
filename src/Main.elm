module Main exposing (..)

import Browser
import Html
import Html.Events
import Random
import Set

type alias Model =
    { rollResult : Maybe Int
    , day : Int
    , maxTime : Int
    , time : Int
    , experience : Int
    , maxHitPoints : Int
    , hitPoints : Int
    , maxMagicPoints : Int
    , magicPoints : Int
    , attack : Int
    , defense : Int
    , gold : Int
    , inventory : List String
    , weapons : List String
    , equippedWeapon : Maybe String
    , armors : List String
    , equippedArmor : Maybe String
    , skills : Set.Set String
    , increaseMaxHitPointFlag : Bool
    , increaseAttackFlag : Bool
    , increaseDefenseFlag : Bool
    }

type Msg
    = RollDie
    | GotRollResult Int
    | Inn
    | Explore
    | SpringTrap
    | Fight Monster
    | GainGold
    | GainPotion
    | BuyPotion
    | UsePotion
    | GainCopperKnife
    | BuyCopperKnife
    | EquipCopperKnife
    | UnEquipCopperKnife
    | SavePoint
    | IncreaseMaxHitPoints
    | IncreaseAttack
    | IncreaseDefense
    | LearnForestWalk
    | UseForestWalk
    | GainLeatherArmor
    | BuyLeatherArmor
    | EquipLeatherArmor
    | UnEquipLeatherArmor

type alias Monster =
    { name : String
    , attack : Int
    , defense : Int
    , expYield : Int
    , goldYield : Int
    }

squirrel : Monster
squirrel =
    { name = "Squirrel"
    , attack = 1
    , defense = 1
    , expYield = 1
    , goldYield = 1
    }

bossSquirrel : Monster
bossSquirrel =
    { name = "Boss Squirrel"
    , attack = 8
    , defense = 2
    , expYield = 10
    , goldYield = 10
    }

owl : Monster
owl =
    { name = "Owl"
    , attack = 1
    , defense = 2
    , expYield = 1
    , goldYield = 2
    }

wolf : Monster
wolf =
    { name = "Wolf"
    , attack = 3
    , defense = 3
    , expYield = 3
    , goldYield = 3
    }

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
            { rollResult = Nothing
            , day = 1
            , maxTime = 3
            , time = 3
            , experience = 0
            , maxHitPoints = 8
            , hitPoints = 8
            , maxMagicPoints = 1
            , magicPoints = 1
            , attack = 1
            , defense = 0
            , gold = 0
            , inventory = []
            , weapons = []
            , equippedWeapon = Nothing
            , armors = []
            , equippedArmor = Nothing
            , skills = Set.empty
            , increaseMaxHitPointFlag = False
            , increaseAttackFlag = False
            , increaseDefenseFlag = False
            }
    in   
    ( initModel, Cmd.none )

-- VIEW

view : Model -> Html.Html Msg
view model =
    Html.ul
        []
        [ Html.li [] 
            [ Html.button [ Html.Events.onClick RollDie ] [ Html.text <| "Roll Die" ]
            , Html.text <| "Result: " ++ Maybe.withDefault "Nothing" (Maybe.map String.fromInt model.rollResult)
            ]
        , Html.li [] [ Html.text <| "Day: " ++ String.fromInt model.day ]
        , Html.li [] [ Html.text <| "Time: " ++ String.fromInt model.time ++ " / " ++ String.fromInt model.maxTime ]
        , Html.li [] [ Html.text <| "EXP: " ++ String.fromInt model.experience ]
        , Html.li [] [ Html.text <| "HP: " ++ String.fromInt model.hitPoints ++ " / " ++ String.fromInt model.maxHitPoints ]
        , Html.li [] [ Html.text <| "MP: " ++ String.fromInt model.magicPoints ++ " / " ++ String.fromInt model.maxMagicPoints ]
        , Html.li [] [ Html.text <| "ATK: " ++ String.fromInt model.attack ]
        , Html.li [] [ Html.text <| "DEF: " ++ String.fromInt model.defense ]
        , Html.li [] [ Html.text <| "Gold: " ++ String.fromInt model.gold ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Inventory: " ]
            , Html.ul 
                []
                ( List.map (\item -> Html.button [ Html.Events.onClick UsePotion ] [ Html.text item ]) model.inventory )
            ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Weapons: " ]
            , Html.ul 
                []
                ( List.map (\weapon -> Html.button [ Html.Events.onClick EquipCopperKnife ] [ Html.text weapon ]) model.weapons )
            ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Equipped Weapon: " ]
            , Html.ul 
                []
                [ Html.button (equippedWeaponActions model.equippedWeapon) [ Html.text <| Maybe.withDefault "Nothing" model.equippedWeapon ] ]
            ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Armor: " ]
            , Html.ul 
                []
                ( List.map (\armor -> Html.button [ Html.Events.onClick EquipLeatherArmor ] [ Html.text armor ]) model.armors )
            ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Equipped Armor: " ]
            , Html.ul 
                []
                [ Html.button (equippedArmorActions model.equippedArmor) [ Html.text <| Maybe.withDefault "Nothing" model.equippedArmor ] ]
            ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Skills: " ]
            , Html.ul 
                []
                ( List.map (\skill -> Html.button [ Html.Events.onClick UseForestWalk ] [ Html.text skill ]) (Set.toList model.skills) )
            ]
        , Html.li [] [ Html.button [ Html.Events.onClick Inn ] [ Html.text <| "Inn" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick Explore ] [ Html.text <| "Explore" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick SpringTrap ] [ Html.text <| "Spring Trap" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick (Fight squirrel) ] [ Html.text <| "Fight Squirrel" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick (Fight owl) ] [ Html.text <| "Fight Owl" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick (Fight wolf) ] [ Html.text <| "Fight Wolf" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick (Fight bossSquirrel) ] [ Html.text <| "Fight Boss Squirrel" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick GainGold ] [ Html.text <| "Gain Gold" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick GainPotion ] [ Html.text <| "Gain Potion" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick BuyPotion ] [ Html.text <| "Buy Potion" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick GainCopperKnife ] [ Html.text <| "Gain Copper Knife" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick BuyCopperKnife ] [ Html.text <| "Buy Copper Knife" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick GainLeatherArmor ] [ Html.text <| "Gain Leather Armor" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick BuyLeatherArmor ] [ Html.text <| "Buy Leather Armor" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick SavePoint ] [ Html.text <| "Save Point" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick IncreaseMaxHitPoints ] [ Html.text <| "Increase Max HP" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick IncreaseAttack ] [ Html.text <| "Increase ATK" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick IncreaseDefense ] [ Html.text <| "Increase DEF" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick LearnForestWalk ] [ Html.text <| "Learn Forest Walk" ] ]
        ]

equippedWeaponActions : Maybe String -> List (Html.Attribute Msg)
equippedWeaponActions m =
    case m of
        Nothing -> 
            []
        
        Just _ -> 
            [ Html.Events.onClick UnEquipCopperKnife ]

equippedArmorActions : Maybe String -> List (Html.Attribute Msg)
equippedArmorActions m =
    case m of
        Nothing -> 
            []
        
        Just _ -> 
            [ Html.Events.onClick UnEquipLeatherArmor ]

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
    case msg of
        RollDie ->
            updateRollDie model
        
        GotRollResult result ->
            updateGotRollResult result model
        
        Inn ->
            updateInn model
        
        Explore ->
            updateExplore model
        
        SpringTrap ->
            updateSpringTrap model
        
        Fight monster ->
            updateFight monster model
        
        GainGold ->
            updateGainGold model
        
        GainPotion ->
            updateGainPotion model
        
        BuyPotion ->
            updateBuyPotion model
        
        GainCopperKnife ->
            updateGainCopperKnife model
        
        BuyCopperKnife ->
            updateBuyCopperKnife model
        
        EquipCopperKnife ->
            updateEquipCopperKnife model
        
        UnEquipCopperKnife ->
            updateUnEquipCopperKnife model
        
        UsePotion ->
            updateUsePotion model
        
        SavePoint ->
            updateSavePoint model
        
        IncreaseMaxHitPoints ->
            updateIncreaseMaxHitPoints model
        
        IncreaseAttack ->
            updateIncreaseAttack model
        
        IncreaseDefense ->
            updateIncreaseDefense model
        
        LearnForestWalk ->
            updateLearnForestWalk model
        
        UseForestWalk ->
            updateUseForestWalk model
        
        GainLeatherArmor ->
            updateGainLeatherArmor model
        
        BuyLeatherArmor ->
            updateBuyLeatherArmor model
        
        EquipLeatherArmor ->
            updateEquipLeatherArmor model
        
        UnEquipLeatherArmor ->
            updateUnEquipLeatherArmor model

updateRollDie : Model -> ( Model, Cmd Msg )
updateRollDie model =
    let
        getRollResultCmd =
            Random.generate GotRollResult (Random.int 1 6)  
    in
    ( model, getRollResultCmd )

updateGotRollResult : Int -> Model -> ( Model, Cmd Msg )
updateGotRollResult result model =
    let
        newModel =
            { model
                | rollResult = Just result
            }
    in
    ( newModel, Cmd.none )

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

updateFight : Monster -> Model -> ( Model, Cmd Msg )
updateFight monster model =
    let
        damage = max (monster.attack - model.defense) 0
        expGain = if model.attack >= monster.defense then monster.expYield else 0
        goldGain = if model.attack >= monster.defense then monster.goldYield else 0
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
                | inventory = "Potion" :: model.inventory
            }
    in
    ( newModel, Cmd.none )

updateBuyPotion : Model -> ( Model, Cmd Msg )
updateBuyPotion model =
    let
        paid = if model.gold >= 2 then 2 else 0
        newItems = if model.gold >= 2 then [ "Potion" ] else []
        newModel =
            { model
                | inventory = List.append newItems model.inventory
                , gold = model.gold - paid
            }
    in
    ( newModel, Cmd.none )

updateGainCopperKnife : Model -> ( Model, Cmd Msg )
updateGainCopperKnife model =
    let
        newModel =
            { model
                | weapons = "Copper Knife" :: model.weapons
            }
    in
    ( newModel, Cmd.none )

updateBuyCopperKnife : Model -> ( Model, Cmd Msg )
updateBuyCopperKnife model =
    let
        paid = if model.gold >= 10 then 10 else 0
        newWeapons = if model.gold >= 10 then [ "Copper Knife" ] else []
        newModel =
            { model
                | weapons = List.append newWeapons model.weapons
                , gold = model.gold - paid
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

updateEquipCopperKnife : Model -> ( Model, Cmd Msg )
updateEquipCopperKnife model =
    let
        newModel =
            { model
                | weapons = Maybe.withDefault [] (List.tail model.weapons)
                , equippedWeapon = Just "Copper Knife"
                , attack = model.attack + 1
            }
    in
    ( newModel, Cmd.none )

updateUnEquipCopperKnife : Model -> ( Model, Cmd Msg )
updateUnEquipCopperKnife model =
    let
        newModel =
            { model
                | weapons = "Copper Knife" :: model.weapons
                , equippedWeapon = Nothing
                , attack = model.attack - 1
            }
    in
    ( newModel, Cmd.none )

updateSavePoint : Model -> ( Model, Cmd Msg )
updateSavePoint model =
    let
        hpGain = (model.maxHitPoints // 10) + 1
        mpGain = (model.maxMagicPoints // 10) + 1
        newModel =
            { model
                | hitPoints = min (model.hitPoints + hpGain) model.maxHitPoints
                , magicPoints = min (model.magicPoints + mpGain) model.maxMagicPoints
            }
    in
    ( newModel, Cmd.none )

updateIncreaseMaxHitPoints : Model -> ( Model, Cmd Msg )
updateIncreaseMaxHitPoints model =
    let
        condition = model.experience >= 5 && not model.increaseMaxHitPointFlag
        expPaid = if condition then 5 else 0
        maxHitPointsGained = if condition then 1 else 0 
        newModel =
            { model
                | maxHitPoints = model.maxHitPoints + maxHitPointsGained
                , experience = model.experience - expPaid
                , increaseMaxHitPointFlag = True
            }
    in
    ( newModel, Cmd.none )

updateIncreaseAttack : Model -> ( Model, Cmd Msg )
updateIncreaseAttack model =
    let
        condition = model.experience >= 7 && not model.increaseAttackFlag
        expPaid = if condition then 7 else 0
        attackGained = if condition then 1 else 0 
        newModel =
            { model
                | attack = model.attack + attackGained
                , experience = model.experience - expPaid
                , increaseAttackFlag = True
            }
    in
    ( newModel, Cmd.none )

updateIncreaseDefense : Model -> ( Model, Cmd Msg )
updateIncreaseDefense model =
    let
        condition = model.experience >= 9 && not model.increaseDefenseFlag
        expPaid = if condition then 9 else 0
        defenseGained = if condition then 1 else 0 
        newModel =
            { model
                | defense = model.defense + defenseGained
                , experience = model.experience - expPaid
                , increaseDefenseFlag = True
            }
    in
    ( newModel, Cmd.none )

updateLearnForestWalk : Model -> ( Model, Cmd Msg )
updateLearnForestWalk model =
    let
        condition = model.experience >= 2
        expPaid = if condition then 2 else 0
        newSkills =
            if condition then
                Set.insert "Forest Walk" model.skills
            else
                model.skills
        newModel =
            { model
                | skills = newSkills
                , experience = model.experience - expPaid
            }
    in
    ( newModel, Cmd.none )

updateUseForestWalk : Model -> ( Model, Cmd Msg )
updateUseForestWalk model =
    let
        magicCost = if model.magicPoints >= 1 then 1 else 0
        newModel =
            { model
                | magicPoints = model.magicPoints - magicCost
            }
    in
    ( newModel, Cmd.none )

updateGainLeatherArmor : Model -> ( Model, Cmd Msg )
updateGainLeatherArmor model =
    let
        newModel =
            { model
                | armors = "Leather Armor" :: model.armors
            }
    in
    ( newModel, Cmd.none )

updateBuyLeatherArmor : Model -> ( Model, Cmd Msg )
updateBuyLeatherArmor model =
    let
        paid = if model.gold >= 18 then 18 else 0
        newArmors = if model.gold >= 18 then [ "Leather Armor" ] else []
        newModel =
            { model
                | armors = List.append newArmors model.armors
                , gold = model.gold - paid
            }
    in
    ( newModel, Cmd.none )

updateEquipLeatherArmor : Model -> ( Model, Cmd Msg )
updateEquipLeatherArmor model =
    let
        newModel =
            { model
                | weapons = Maybe.withDefault [] (List.tail model.weapons)
                , equippedArmor = Just "LeatherArmor"
                , defense = model.defense + 1
            }
    in
    ( newModel, Cmd.none )

updateUnEquipLeatherArmor : Model -> ( Model, Cmd Msg )
updateUnEquipLeatherArmor model =
    let
        newModel =
            { model
                | armors = "Leather Armor" :: model.armors
                , equippedArmor = Nothing
                , defense = model.defense - 1
            }
    in
    ( newModel, Cmd.none )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none