module Main exposing (..)

import Browser
import Html
import Html.Events
import Random
import Random.Extra
import Set

type alias Model =
    { mode : Mode
    , rollResult : Maybe Int
    , day : Int
    , maxTime : Int
    , time : Int
    , level : Int
    , totalExperience : Int
    , experience : Int
    , maxHitPoints : Int
    , hitPoints : Int
    , maxMagicPoints : Int
    , magicPoints : Int
    , attack : Int
    , defense : Int
    , agility : Int
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
    , encounteredMonster : Maybe Monster
    , messages : List String
    , activeSkills : Set.Set String
    , depth : Int
    , maps : List Map
    , currentMap : Maybe Map
    , poison : Maybe Int
    , residence : String
    }

type Msg
    = Inn
    | Explore Map
    | SpringTrap
    | Fight
    | BossFight Monster
    | Flee
    | BuyDonut
    | UseDonut
    | BuyCopperKnife
    | EquipCopperKnife
    | UnEquipCopperKnife
    | SavePoint
    | IncreaseMaxHitPoints
    | IncreaseAttack
    | IncreaseDefense
    | LearnForestWalk
    | UseForestWalk
    | BuyLeatherArmor
    | EquipLeatherArmor
    | UnEquipLeatherArmor
    | GenerateTreasure (Random.Generator Treasure)
    | GetTreasure Treasure
    | GenerateMonster (Random.Generator Monster)
    | GetMonster Monster
    | Leave
    | Continue
    | GetExploreNode ExploreNode
    | GetMap Map
    | DoWork

type Mode
    = Exploring ExploreNode
    | NotExploring

type ExploreNode
    = TerrainNode
    | TrapNode
    | MonsterNode
    | TreasureNode TreasureQuality
    | SavePointNode
    | GoalNode

type alias Map =
    { name : String
    , level : Int
    , depth : Int
    , exploreNodeGenerator : Random.Generator ExploreNode
    , monsterGenerator : Random.Generator Monster
    , minorTreasureGenerator : Random.Generator Treasure
    , majorTreasureGenerator : Random.Generator Treasure
    , goalTreasureGenerator : Random.Generator Treasure
    }

mapGenerator : Int -> Random.Generator Map
mapGenerator level =
    let
        levelGenerator =
            Random.int (level + 1) (round ((toFloat level) * 1.5) + 1)
        
        byLevel generator =
            levelGenerator
                |> Random.andThen generator
        
        nameGenerator genLv =
            Random.constant <| "Forest Lv. " ++ String.fromInt genLv
        
        depthGenerator genLv =
            Random.int (10 + genLv) (10 + (2 * genLv))
        
        exploreNodeGeneratorGenerator genLv =
            let
                distribution lower upper node =
                    Random.int lower upper
                        |> Random.andThen (\freq -> Random.constant ( toFloat freq, node ))
                
                savePointNodeDistributionGenerator =
                    distribution 1 (1 + (genLv // 4)) SavePointNode
                
                otherExploreNodesDistributionGenerator =
                    ( distribution 4 (4 + (genLv // 2)) TerrainNode ) |> Random.andThen (\terrainNodeDistribution ->
                    ( distribution 2 (2 + genLv) TrapNode ) |> Random.andThen (\trapNodeDistribution ->
                    ( distribution 6 (6 + genLv) MonsterNode ) |> Random.andThen (\monsterNodeDistribution ->
                    ( distribution 6 (6 + (genLv // 2)) (TreasureNode MinorTreasureQuality) ) |> Random.andThen (\minorTreasureNodeDistribution ->
                    ( distribution 2 (2 + (genLv // 4)) (TreasureNode MajorTreasureQuality) ) |> Random.andThen (\majorTreasureNodeDistribution ->
                        Random.constant <|
                            [ terrainNodeDistribution
                            , trapNodeDistribution
                            , monsterNodeDistribution
                            , minorTreasureNodeDistribution
                            , majorTreasureNodeDistribution
                            ]
                    )))))
            in
            Random.map2 Random.weighted
                savePointNodeDistributionGenerator
                otherExploreNodesDistributionGenerator
        
        monsterGeneratorGenerator genLv =
            let
                encounterRate gLv monster =
                    let
                        suitability = 1 / (toFloat ((monster.level - gLv) * (monster.level - gLv)) + 1)
                        encounterRateModifier = frequencyToFloat monster.encounterRate
                    in
                    suitability * encounterRateModifier
                
                minViableEncounterRate = 1 / 256
                
                monsterDistributionList =
                    allMonsters
                        |> List.map (\m -> ( encounterRate genLv m, m ))
                        |> List.filter (\(r, m) -> (r >= minViableEncounterRate))
                
                uncons xls =
                    case xls of
                        x :: xs ->
                            Just (x, xs)

                        [] ->
                            Nothing
                
                monsterGenerator =
                    case uncons monsterDistributionList of
                        Just ( head, tail ) ->
                            Random.weighted head tail
                        
                        Nothing ->
                            Random.constant missingno
            in
            Random.constant monsterGenerator

        minorTreasureGeneratorGenerator genLv =
            let
                minorTreasureGenerator =
                    Random.weighted
                        ( 1, TrapTreasure 1 )
                        [ ( 3, EmptyTreasure )
                        , ( 1, GoldTreasure 1 )
                        , ( 1, ItemTreasure "Donut" )
                        ]
            in
            Random.constant minorTreasureGenerator
        
        majorTreasureGeneratorGenerator genLv =
            let
                majorTreasureGenerator =
                    Random.weighted
                        ( 1, TrapTreasure 1 )
                        [ ( 3, GoldTreasure 1 )
                        , ( 3, ItemTreasure "Donut" )
                        , ( 1, WeaponTreasure "Copper Knife" )
                        , ( 1, ArmorTreasure "Leather Armor" )
                        ]
            in
            Random.constant majorTreasureGenerator
        
        goalTreasureGeneratorGenerator genLv =
            let
                goalTreasureGenerator =
                    Random.weighted
                        ( 1, WeaponTreasure "Copper Knife" )
                        [ ( 1, ArmorTreasure "Leather Armor" )
                        ]
            in
            Random.constant goalTreasureGenerator
    in
    Random.map Map ( byLevel nameGenerator )
        |> Random.Extra.andMap levelGenerator
        |> Random.Extra.andMap ( byLevel depthGenerator )
        |> Random.Extra.andMap ( byLevel exploreNodeGeneratorGenerator )
        |> Random.Extra.andMap ( byLevel monsterGeneratorGenerator )
        |> Random.Extra.andMap ( byLevel minorTreasureGeneratorGenerator )
        |> Random.Extra.andMap ( byLevel majorTreasureGeneratorGenerator )
        |> Random.Extra.andMap ( byLevel goalTreasureGeneratorGenerator )

exploreNodeToString : ExploreNode -> String
exploreNodeToString exploreNode =
    case exploreNode of      
        TerrainNode ->
            "Terrain"
        
        TrapNode ->
            "Trap"
        
        MonsterNode ->
            "Monster"
        
        TreasureNode treasureQuality ->
            case treasureQuality of
                MinorTreasureQuality ->
                    "Minor Treasure"
                
                MajorTreasureQuality ->
                    "Major Treasure"
                
                GoalTreasureQuality ->
                    "Goal Treasure"
        
        SavePointNode ->
            "Save Point"
        
        GoalNode ->
            "Goal"

type TreasureQuality
    = MinorTreasureQuality
    | MajorTreasureQuality
    | GoalTreasureQuality

type alias Monster =
    { level : Int
    , encounterRate : Frequency
    , name : String
    , attack : Int
    , defense : Int
    , agility : Int
    , expYield : Int
    , goldYield : Int
    , poison : Maybe Int
    }

type Frequency
    = Common
    | Uncommon
    | Rare
    | Legendary

frequencyToFloat : Frequency -> Float
frequencyToFloat freq =
    case freq of
        Common ->
            1
        
        Uncommon ->
            1 / 4

        Rare ->
            1 / 16
        
        Legendary ->
            1 / 64

missingno : Monster
missingno =
    { level = 99
    , encounterRate = Common
    , name = "Missingno"
    , attack = 0
    , defense = 0
    , agility = 0
    , expYield = 0
    , goldYield = 0
    , poison = Nothing
    }

pigeon : Monster
pigeon =
    { level = 1
    , encounterRate = Common
    , name = "Pigeon"
    , attack = 1
    , defense = 1
    , agility = 2
    , expYield = 1
    , goldYield = 1
    , poison = Nothing
    }

bossPigeon : Monster
bossPigeon =
    { level = 2
    , encounterRate = Legendary
    , name = "Boss Pigeon"
    , attack = 8
    , defense = 2
    , agility = 1
    , expYield = 10
    , goldYield = 10
    , poison = Nothing
    }

owl : Monster
owl =
    { level = 1
    , encounterRate = Uncommon
    , name = "Owl"
    , attack = 1
    , defense = 2
    , agility = 1
    , expYield = 1
    , goldYield = 2
    , poison = Nothing
    }

snake : Monster
snake =
    { level = 2
    , encounterRate = Uncommon
    , name = "Snake"
    , attack = 1
    , defense = 1
    , agility = 1
    , expYield = 1
    , goldYield = 2
    , poison = Just 1
    }

wolf : Monster
wolf =
    { level = 2
    , encounterRate = Common
    , name = "Wolf"
    , attack = 3
    , defense = 3
    , agility = 1
    , expYield = 3
    , goldYield = 3
    , poison = Nothing
    }

bear : Monster
bear =
    { level = 3
    , encounterRate = Uncommon
    , name = "Bear"
    , attack = 7
    , defense = 5
    , agility = 1
    , expYield = 6
    , goldYield = 6
    , poison = Nothing
    }

allMonsters =
    [ pigeon
    , owl
    , snake
    , wolf
    , bear
    ]

type Treasure
    = TrapTreasure Int
    | EmptyTreasure
    | GoldTreasure Int
    | ItemTreasure String
    | WeaponTreasure String
    | ArmorTreasure String

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

-- INIT

init : flags -> ( Model, Cmd Msg )
init _ =
    let
        initModel =
            { mode = NotExploring
            , rollResult = Nothing
            , day = 1
            , maxTime = 3
            , time = 3
            , level = 1
            , totalExperience = 0
            , experience = 0
            , maxHitPoints = 8
            , hitPoints = 8
            , maxMagicPoints = 1
            , magicPoints = 1
            , attack = 1
            , defense = 0
            , agility = 1
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
            , encounteredMonster = Nothing
            , messages = []
            , activeSkills = Set.empty
            , depth = 0
            , maps = []
            , currentMap = Nothing
            , poison = Nothing
            , residence = "Hostel"
            }
    in   
    ( initModel, generateMap 0 )

generateMap : Int -> Cmd Msg
generateMap level =
    Random.generate GetMap ( mapGenerator level )

-- VIEW

view : Model -> Html.Html Msg
view model =
    Html.ul
        []
        [ Html.li [] [ Html.text <| "Residence: " ++ model.residence ]
        , Html.li [] [ Html.text <| "Day: " ++ String.fromInt model.day ]
        , Html.li [] [ Html.text <| "Time: " ++ String.fromInt model.time ++ " / " ++ String.fromInt model.maxTime ]
        , Html.li [] [ Html.text <| "Level: " ++ String.fromInt model.level ]
        , Html.li [] [ Html.text <| "EXP: " ++ String.fromInt model.experience ++ " / " ++ String.fromInt model.totalExperience ++ " / " ++ String.fromInt (model.level * model.level * 10) ]
        , Html.li [] [ Html.text <| "HP: " ++ String.fromInt model.hitPoints ++ " / " ++ String.fromInt model.maxHitPoints ]
        , ( case model.poison of
            Just poisonStacks ->
                Html.li [] [ Html.text <| "Poison: " ++ String.fromInt poisonStacks ]

            Nothing ->
                Html.node "blank" [] []
          )
        , Html.li [] [ Html.text <| "MP: " ++ String.fromInt model.magicPoints ++ " / " ++ String.fromInt model.maxMagicPoints ]
        , Html.li [] [ Html.text <| "ATK: " ++ String.fromInt model.attack ]
        , Html.li [] [ Html.text <| "DEF: " ++ String.fromInt model.defense ]
        , Html.li [] [ Html.text <| "AGI: " ++ String.fromInt model.agility ]
        , Html.li [] [ Html.text <| "Gold: " ++ String.fromInt model.gold ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Inventory: " ]
            , Html.ul 
                []
                ( List.map (\item -> Html.button [ Html.Events.onClick UseDonut ] [ Html.text item ]) model.inventory )
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
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Active Skills: " ]
            , Html.ul 
                []
                ( List.map (\skill -> Html.li [] [ Html.text skill ]) (Set.toList model.activeSkills) )
            ]
        , case model.mode of
            Exploring exploreNode ->
                viewExploring exploreNode model
            
            NotExploring ->
                viewNotExploring model
        ]

viewOption : Msg -> String -> Html.Html Msg
viewOption msg text =
    Html.li []
        [ Html.button [ Html.Events.onClick msg ]
            [ Html.text text
            ]
        ]

getTreasureGenerator : TreasureQuality -> Model -> Random.Generator Treasure
getTreasureGenerator treasureQuality model =
    let
        defaultGenerator =
            Random.constant EmptyTreasure
        
        getter =
            case treasureQuality of
                MinorTreasureQuality ->
                    .minorTreasureGenerator
                
                MajorTreasureQuality ->
                    .majorTreasureGenerator
                
                GoalTreasureQuality ->
                    .goalTreasureGenerator
    in
    model.currentMap
        |> Maybe.map getter
        |> Maybe.withDefault defaultGenerator

viewExploring : ExploreNode -> Model -> Html.Html Msg
viewExploring exploreNode model =
    let
        messages = model.messages
        options =
            case exploreNode of
                TerrainNode ->
                    if Set.member "Forest Walk" model.activeSkills then
                        [ viewOption Leave "Leave"
                        , viewOption Continue "Continue"
                        ]
                    else
                        [ viewOption Leave "Leave"
                        ]
                
                TrapNode ->
                    [ viewOption Leave "Leave"
                    , viewOption SpringTrap "Spring Trap"
                    ]
                
                MonsterNode ->
                    [ case model.encounteredMonster of
                        Just monster ->
                            Html.ul []
                                [ Html.li [] [ Html.text <| "Name: " ++ monster.name ]
                                , Html.li [] [ Html.text <| "Attack: " ++ String.fromInt monster.attack ]
                                , Html.li [] [ Html.text <| "Defense: " ++ String.fromInt monster.defense ]
                                , case monster.poison of
                                    Just psn ->
                                        Html.li [] [ Html.text <| "Poison: " ++ String.fromInt psn ]
                                    Nothing ->
                                        Html.node "blank" [] []
                                
                                , Html.li [] [ Html.text <| "EXP Yield: " ++ String.fromInt monster.expYield ]
                                , Html.li [] [ Html.text <| "Gold Yield: " ++ String.fromInt monster.goldYield ]
                                ]
                        Nothing ->
                            Html.node "blank" [] []

                    , viewOption Fight "Fight"
                    , viewOption Flee "Flee"
                    ]
                
                TreasureNode treasureQuality ->
                    let
                        treasureDesc =
                            case treasureQuality of
                                MinorTreasureQuality ->
                                    { generator = GenerateTreasure <| getTreasureGenerator MinorTreasureQuality model
                                    , label = "Cut Bush"
                                    }
                                
                                MajorTreasureQuality ->
                                    { generator = GenerateTreasure <| getTreasureGenerator MajorTreasureQuality model
                                    , label = "Open Chest"
                                    }
                                
                                GoalTreasureQuality ->
                                    { generator = GenerateTreasure <| getTreasureGenerator GoalTreasureQuality model
                                    , label = "Open Chest"
                                    }
                    in
                    [ viewOption Continue "Continue"
                    , viewOption treasureDesc.generator treasureDesc.label
                    ]
            
                SavePointNode ->
                    [ viewOption Leave "Leave"
                    , viewOption Continue "Continue"
                    ]
                
                GoalNode ->
                    [ viewOption Leave "Leave"
                    ]

    in
    Html.ul []
        [ Html.li [] [ Html.text <| "Node: " ++ exploreNodeToString exploreNode ]
        , Html.li [] [ Html.text <| "Depth: " ++ String.fromInt model.depth ]
        , Html.ul [] options
        , Html.ul [] (List.map (\m -> (Html.li [] [ Html.text m ])) messages )
        ]

viewNotExploring : Model -> Html.Html Msg
viewNotExploring model =
    Html.ul []
        [ Html.li [] [ Html.button [ Html.Events.onClick Inn ] [ Html.text <| "Inn" ] ]
        , Html.li []
            ( List.map (\map -> Html.button [ Html.Events.onClick <| Explore map ] [ Html.text <| "Explore: " ++ map.name ]) model.maps )
        , Html.li [] [ Html.button [ Html.Events.onClick (BossFight bossPigeon) ] [ Html.text <| "Fight Boss Pigeon" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick DoWork ] [ Html.text <| "Do Work" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick BuyDonut ] [ Html.text <| "Buy Donut" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick BuyCopperKnife ] [ Html.text <| "Buy Copper Knife" ] ]
        
        , Html.li [] [ Html.button [ Html.Events.onClick BuyLeatherArmor ] [ Html.text <| "Buy Leather Armor" ] ]
        
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
    case ( msg, model.mode ) of
        ( Inn, NotExploring ) ->
            updateInn model
        
        ( Explore map, NotExploring ) ->
            updateExplore map model
        
        ( SpringTrap, Exploring TrapNode ) ->
            updateSpringTrap model
        
        ( Fight, Exploring MonsterNode ) ->
            updateFight model
        
        ( BossFight monster, NotExploring ) ->
            updateBossFight monster model
        
        ( Flee, Exploring MonsterNode ) ->
            updateFlee model
        
        ( BuyDonut, NotExploring ) ->
            updateBuyDonut model
        
        ( BuyCopperKnife, NotExploring ) ->
            updateBuyCopperKnife model
        
        ( EquipCopperKnife, _ ) ->
            updateEquipCopperKnife model
        
        ( UnEquipCopperKnife, _ ) ->
            updateUnEquipCopperKnife model
        
        ( UseDonut, _ ) ->
            updateUseDonut model
        
        ( SavePoint, Exploring SavePointNode ) ->
            updateSavePoint model
        
        ( IncreaseMaxHitPoints, _ ) ->
            updateIncreaseMaxHitPoints model
        
        ( IncreaseAttack, _ ) ->
            updateIncreaseAttack model
        
        ( IncreaseDefense, _ ) ->
            updateIncreaseDefense model
        
        ( LearnForestWalk, _ ) ->
            updateLearnForestWalk model
        
        ( UseForestWalk, Exploring _ ) ->
            updateUseForestWalk model
        
        ( BuyLeatherArmor, NotExploring ) ->
            updateBuyLeatherArmor model
        
        ( EquipLeatherArmor, _ ) ->
            updateEquipLeatherArmor model
        
        ( UnEquipLeatherArmor, _ ) ->
            updateUnEquipLeatherArmor model
        
        ( GenerateTreasure distribution, _ ) ->
            updateGenerateTreasure distribution model
        
        ( GetTreasure treasure, Exploring GoalNode ) ->
            updateGetTreasure False treasure model
        
        ( GetTreasure treasure, Exploring _ ) ->
            updateGetTreasure True treasure model
        
        ( GetTreasure treasure, _ ) ->
            updateGetTreasure False treasure model
        
        ( GenerateMonster distribution, Exploring MonsterNode ) ->
            updateGenerateMonster distribution model
        
        ( GetMonster monster, Exploring MonsterNode ) ->
            updateGetMonster monster model
        
        ( Leave, Exploring _ ) ->
            updateLeave model
        
        ( Continue, Exploring _ ) ->
            updateContinue model
        
        ( GetExploreNode exploreNode, _ ) ->
            updateGetExploreNode exploreNode model
        
        ( GetMap map, _ ) ->
            updateGetMap map model
        
        ( DoWork, NotExploring ) ->
            updateDoWork model
        
        _ ->
            ( model, Cmd.none )

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

updateExplore : Map -> Model -> ( Model, Cmd Msg )
updateExplore map model =
    let
        canExplore = model.time >= 1
        timeCost = if canExplore then 1 else 0
        nextCmd = if canExplore then getNextExploreNode (Just map) else Cmd.none
        newModel =
            { model
                | time = model.time - timeCost
                , messages = []
                , activeSkills = Set.empty
                , depth = 0
                , currentMap = Just map
            }
    in
    ( newModel, nextCmd )

updateSpringTrap : Model -> ( Model, Cmd Msg )
updateSpringTrap model =
    let 
        newModel =
            { model
                | hitPoints = max (model.hitPoints - 1) 0
            }
    in
    ( newModel, getNextExploreNode model.currentMap )

updateBossFight : Monster -> Model -> ( Model, Cmd Msg )
updateBossFight monster model =
    let
        damage = max (monster.attack - model.defense) 0
        win = model.attack >= monster.defense
        goldGain = if win then monster.goldYield else 0
        expGainer = if win then updateExpGain monster.expYield else \m -> m 
        newPoison =
            case (monster.poison, model.poison) of
                ( Nothing, _ ) ->
                    model.poison
                
                ( Just ps, Nothing ) ->
                    Just ps
                
                ( Just p, Just q) ->
                    Just <| p + q
        
        newModel =
            { model
                | hitPoints = max (model.hitPoints - damage) 0
                , gold = model.gold + goldGain
                , poison = newPoison
            }
                |> expGainer
    in
    ( newModel, Cmd.none )

updateFight : Model -> ( Model, Cmd Msg )
updateFight model =
    let
        newModel =
            case model.encounteredMonster of
                Just monster ->
                    let
                        damage = max (monster.attack - model.defense) 0
                        win = model.attack >= monster.defense
                        goldGain = if model.attack >= monster.defense then monster.goldYield else 0
                        expGainer = if win then updateExpGain monster.expYield else \m -> m
                        newPoison =
                            case (monster.poison, model.poison) of
                                ( Nothing, _ ) ->
                                    model.poison
                                
                                ( Just ps, Nothing ) ->
                                    Just ps
                                
                                ( Just p, Just q) ->
                                    Just <| p + q
                    in
                    { model
                        | hitPoints = max (model.hitPoints - damage) 0
                        , gold = model.gold + goldGain
                        , encounteredMonster = Nothing
                        , poison = newPoison
                    }
                        |> expGainer
                
                Nothing ->
                    model

    in
    ( newModel, getNextExploreNode model.currentMap )

updateExpGain : Int -> Model -> Model
updateExpGain gained model =
    let
        expForNextLevel =
            model.level * model.level * 10
        
        totalExperience =
            model.totalExperience + gained
        
        gainedLevel = totalExperience >= expForNextLevel
        levelGain =
            if gainedLevel then
                1
            else
                0
        
        maxHitPointGain = if gainedLevel then 1 else 0
        maxMagicPointGain = if gainedLevel then 1 else 0
    in
    { model
        | level = model.level + levelGain
        , totalExperience = totalExperience
        , experience = model.experience + gained
        , maxHitPoints = model.maxHitPoints + maxHitPointGain
        , maxMagicPoints = model.maxMagicPoints + maxMagicPointGain
    }
    
updateFlee : Model -> ( Model, Cmd Msg )
updateFlee model =
    let
        newModel =
            case model.encounteredMonster of
                Just monster ->
                    let
                        canFlee = model.agility >= monster.agility
                        damage = max (monster.attack - model.defense) 0
                        fleeDamage = if canFlee then 0 else damage
                    in
                    { model
                        | hitPoints = max (model.hitPoints - fleeDamage) 0
                        , encounteredMonster = Nothing
                        , mode = NotExploring
                        , activeSkills = Set.empty
                        , currentMap = Nothing
                    }
                
                Nothing ->
                    model
    in
    ( newModel, Cmd.none )

updateBuyDonut : Model -> ( Model, Cmd Msg )
updateBuyDonut model =
    let
        paid = if model.gold >= 2 then 2 else 0
        newItems = if model.gold >= 2 then [ "Donut" ] else []
        newModel =
            { model
                | inventory = List.append newItems model.inventory
                , gold = model.gold - paid
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

updateUseDonut : Model -> ( Model, Cmd Msg )
updateUseDonut model =
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
                , activeSkills = Set.insert "Forest Walk" model.activeSkills
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

updateGenerateTreasure : Random.Generator Treasure -> Model -> ( Model, Cmd Msg )
updateGenerateTreasure distribution model =
    let
        newCmd =
            Random.generate GetTreasure distribution
    in
    ( model, newCmd )

updateGetTreasure : Bool -> Treasure -> Model -> ( Model, Cmd Msg )
updateGetTreasure genNext treasure model =
    let
        nextCmd =
            if genNext then getNextExploreNode model.currentMap else Cmd.none
        
        newModel =
            case treasure of
                TrapTreasure damage ->
                    { model | hitPoints = max (model.hitPoints - damage) 0 }
                
                EmptyTreasure ->
                    model
                
                GoldTreasure amount ->
                    { model | gold = model.gold + amount }
                
                ItemTreasure item ->
                    { model | inventory = item :: model.inventory }
                
                WeaponTreasure weapon ->
                    { model | weapons = weapon :: model.weapons }
                
                ArmorTreasure armor ->
                    { model | armors = armor :: model.armors }
    in
    ( newModel, nextCmd )

updateGenerateMonster : Random.Generator Monster -> Model -> ( Model, Cmd Msg )
updateGenerateMonster distribution model =
    let
        newCmd =
            Random.generate GetMonster distribution
    in
    ( model, newCmd )

updateGetMonster : Monster -> Model -> ( Model, Cmd Msg )
updateGetMonster monster model =
    let
        encounterMessage = "A wild " ++ monster.name ++ " appears!"
        newModel =
            { model
                | encounteredMonster = Just monster
                , messages = encounterMessage :: model.messages
            }
    in
    ( newModel, Cmd.none )

updateLeave : Model -> ( Model, Cmd Msg )
updateLeave model =
    let
        newModel =
            { model
                | mode = NotExploring
                , activeSkills = Set.empty
                , currentMap = Nothing
            }
    in
    ( newModel, Cmd.none )

updateContinue : Model -> ( Model, Cmd Msg )
updateContinue model =
    let
        newModel =
            model
        
    in
    ( newModel, getNextExploreNode model.currentMap )

updateGetExploreNode : ExploreNode -> Model -> ( Model, Cmd Msg )
updateGetExploreNode exploreNode model =
    let
        hpLossFromPoison = Maybe.withDefault 0 model.poison
        maxDepth =
            model.currentMap
                |> Maybe.map .depth
                |> Maybe.withDefault 0
        
        nextExploreNode =
            if model.depth >= maxDepth then GoalNode else exploreNode
        
        monsterGenerator =
            model.currentMap
                |> Maybe.map .monsterGenerator
                |> Maybe.withDefault ( Random.constant missingno )
        
        newCmd =
            case nextExploreNode of
                MonsterNode ->
                    Random.generate GetMonster monsterGenerator
                
                GoalNode ->
                    Cmd.batch
                        [ Random.generate GetTreasure ( getTreasureGenerator GoalTreasureQuality model )
                        , generateMap model.level
                        ]
                
                _ ->
                    Cmd.none
        
        newModel =
            case nextExploreNode of
                SavePointNode ->
                    let
                        hpGain = (model.maxHitPoints // 10) + 1
                        mpGain = (model.maxMagicPoints // 10) + 1
                    in
                    { model
                        | hitPoints = min (model.hitPoints + hpGain) model.maxHitPoints
                        , magicPoints = min (model.magicPoints + mpGain) model.maxMagicPoints
                    }
                
                _ ->
                    model
        
        nextMessages =
            case nextExploreNode of
                TerrainNode ->
                    if Set.member "Forest Walk" newModel.activeSkills then
                        [ "You find a dense grove of trees. You find a narrow path between them to continue." ]
                    else
                        [ "You find a dense grove of trees. You cannot proceed." ]
                
                TrapNode ->
                    [ "You sense danger..." ]
                
                TreasureNode MinorTreasureQuality ->
                    [ "You find a thicket of grass and see something inside it." ]
                
                TreasureNode MajorTreasureQuality ->
                    [ "What luck! You find a treasure chest!" ]
                
                SavePointNode ->
                    [ "You come across a rest area. A path leads back to town." ]
                
                GoalNode ->
                    [ "You reached the goal!" ]
                
                _ ->
                    []
        
        newModel2 =
            { newModel
                | mode = Exploring nextExploreNode
                , messages = List.append nextMessages newModel.messages
                , depth = newModel.depth + 1
                , hitPoints = max (newModel.hitPoints - hpLossFromPoison) 0
            }
    in
    ( newModel2, newCmd )

getNextExploreNode : Maybe Map -> Cmd Msg
getNextExploreNode m =
    let
        exploreNodeGenerator =
            m
                |> Maybe.map .exploreNodeGenerator
                |> Maybe.withDefault ( Random.constant GoalNode )  
    in    
    Random.generate GetExploreNode exploreNodeGenerator

updateGetMap : Map -> Model -> ( Model, Cmd Msg )
updateGetMap map model =
    let
        newModel =
            { model
                | maps = map :: model.maps
            }
    in
    ( newModel, Cmd.none )

updateDoWork : Model -> ( Model, Cmd Msg )
updateDoWork model =
    let
        canDoWork = model.time >= 1
        goldDelta = if canDoWork then 1 else 0
        timeDelta = if canDoWork then 1 else 0
        newModel =
            { model
                | gold = model.gold + goldDelta
                , time = model.time - timeDelta
            }
    in
    ( newModel, Cmd.none )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none