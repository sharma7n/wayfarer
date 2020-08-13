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
    , class : Class
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
    , inventory : List Item
    , weapons : List Weapon
    , equippedWeapon : Maybe Weapon
    , armors : List Armor
    , equippedArmor : Maybe Armor
    , skills : List Skill
    , passives : List Passive
    , encounteredMonster : Maybe Monster
    , messages : List String
    , activeSkills : List Skill
    , depth : Int
    , maps : List Map
    , currentMap : Maybe Map
    , poison : Int
    , residence : String
    , furniture : List Furniture
    , encounteredTrap : Maybe Trap
    }

type Msg
    = Inn
    | Explore Map
    | SpringTrap Trap
    | Fight
    | BossFight Monster
    | Flee
    | BuyItem Item
    | UseItem Item
    | BuyWeapon Weapon
    | EquipWeapon Weapon
    | UnEquipWeapon Weapon
    | SavePoint
    | LearnSkill Skill
    | LearnPassive Passive
    | UseSkill Skill
    | BuyArmor Armor
    | EquipArmor Armor
    | UnEquipArmor Armor
    | GenerateTreasure (Random.Generator Treasure)
    | GetTreasure Treasure
    | GetMonster Monster
    | Leave
    | Continue
    | GetExploreNode ExploreNode
    | GetMap Map
    | DoWork
    | BuyFurniture Furniture
    | GetTrap Trap
    | ChangeClass Class

-- CLASS

type Class
    = Commoner
    | Fighter
    | Mage

classToString : Class -> String
classToString class =
    case class of
        Commoner ->
            "Commoner"
        
        Fighter ->
            "Fighter"
        
        Mage ->
            "Mage"

allClasses : List Class
allClasses =
    [ Commoner
    , Fighter
    , Mage
    ]

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
    , trapGenerator : Random.Generator Trap
    }

weight : { a | level : Int, frequency : Frequency } -> Int -> Float
weight a level =
    let
        suitability =
            1 / ( toFloat (a.level - level)^2 + 1 )
    in
    suitability * frequencyToFloat a.frequency

minWeight : Float
minWeight =
    1 / 256

sequenceRandom : List ( Random.Generator a ) -> Random.Generator ( List a )
sequenceRandom randoms =
    List.foldr
        ( Random.map2 (::) )
        ( Random.constant [] )
        randoms

type alias Weighted a =
    { weight : Float
    , value : a
    }

weightedToPair : Weighted a -> ( Float, a )
weightedToPair wt =
    ( wt.weight, wt.value )

type alias LevelFreq a = { a | level : Int, frequency : Frequency }

type alias NonEmptyList a =
    { head : a
    , tail : List a
    }

nonEmptyListToList : NonEmptyList a -> List a
nonEmptyListToList ne =
    ne.head :: ne.tail

nonEmptyWeightedListToGenerator : NonEmptyList (Weighted a) -> Random.Generator a
nonEmptyWeightedListToGenerator news =
    Random.weighted
        ( weightedToPair news.head )
        ( List.map weightedToPair news.tail )

randomTable : LevelFreq a -> List ( LevelFreq a ) -> Int -> Random.Generator (NonEmptyList (Weighted (LevelFreq a)))
randomTable null all level =
    let
        weightedListGenerator =
            all
                |> List.map (\o ->
                    let
                        suitability = 1 / ( (toFloat (o.level - level)^2) + 1  )
                        baseRate = suitability * (frequencyToFloat o.frequency)
                    in
                    ( baseRate, o )
                )
                |> List.map (\(baseRate, o) ->
                    Random.float 0.5 1.5 |> Random.andThen (\genFloat ->
                    Random.constant <| 
                        { weight = genFloat * baseRate
                        , value = o
                        }
                    )
                )
                |> sequenceRandom
                |> Random.map (List.filter (\x -> x.weight >= (1/256)))
    in
    weightedListGenerator |> Random.andThen (\weightedList ->
    Random.constant <|
        { head =
            { weight = 0
            , value = null
            }
        , tail = weightedList
        }
    )

randomWeightedMap : Random.Generator a -> Float -> (a -> b) -> Random.Generator ( Float, b )
randomWeightedMap gen w f =
    gen |> Random.andThen (\g -> Random.constant ( w, f g ))

mapGenerator : Int -> Random.Generator Map
mapGenerator level =
    let
        levelGenerator =
            Random.int (level + 1) (round ((toFloat level) * 1.5) + 1)
        
        goldGenerator : Float -> Random.Generator ( List (Float, Int) )
        goldGenerator factor =
            levelGenerator |> Random.map (\genLv ->
            List.range genLv (genLv * 2)
                |> List.map (\amount ->
                    ( factor / (toFloat genLv), amount )
                )
            )
        
        goldTreasureGenerator : Float -> Random.Generator ( List ( Float, Treasure ) )
        goldTreasureGenerator factor =
            goldGenerator factor
                |> Random.map (List.map (\(f, i) -> (f, GoldTreasure i)))
        
        byLevel generator =
            levelGenerator
                |> Random.andThen generator
        
        nameGenerator genLv =
            Random.constant <| "Forest Lv. " ++ String.fromInt genLv
        
        depthGenerator genLv =
            Random.int (10 + genLv) (10 + (2 * genLv))

        trapGenerator : Random.Generator (NonEmptyList (Weighted Trap))
        trapGenerator =
            byLevel (randomTable nullTrap allTraps)
        
        itemGenerator : Random.Generator (NonEmptyList (Weighted Item))
        itemGenerator =
            byLevel (randomTable nullItem allItems)
        
        weaponGenerator : Random.Generator (NonEmptyList (Weighted Weapon))
        weaponGenerator =
            byLevel (randomTable nullWeapon allWeapons)
        
        armorGenerator : Random.Generator (NonEmptyList (Weighted Armor))
        armorGenerator =
            byLevel (randomTable nullArmor allArmors)
        
        furnitureGenerator : Random.Generator (NonEmptyList (Weighted Furniture))
        furnitureGenerator =
            byLevel (randomTable nullFurniture allFurniture)
        
        monsterGenerator : Random.Generator (NonEmptyList (Weighted Monster))
        monsterGenerator =
            byLevel (randomTable nullMonster allMonsters)
        
        treasurify : Float -> (a -> b) -> Random.Generator (NonEmptyList (Weighted a)) -> Random.Generator ( List (Float, b ))
        treasurify factor toTreasure nwGen =
            nwGen |> Random.map (\nw ->
                nonEmptyListToList nw
                    |> List.map weightedToPair
                    |> List.map (\(w,t) -> (factor * w, toTreasure t))
            )
        
        exploreNodeGeneratorGenerator genLv =
            let
                distribution : Int -> Int -> a -> Random.Generator ( Float, a )
                distribution lower upper node =
                    Random.int lower upper
                        |> Random.andThen (\freq -> Random.constant ( toFloat freq, node ))
                
                savePointNodeDistributionGenerator =
                    distribution 1 (1 + (genLv // 4)) SavePointNode
                
                otherExploreNodesDistributionGenerator =
                    ( distribution 4 (4 + (genLv // 2)) TerrainNode ) |> Random.andThen (\terrainNodeDistribution ->
                    ( distribution 2 (2 + genLv)) TrapNode |> Random.andThen (\trapNodeDistribution ->
                    ( distribution 6 (6 + genLv) MonsterNode ) |> Random.andThen (\monsterNodeDistribution ->
                    ( distribution 6 (6 + (genLv // 2)) (TreasureNode MinorTreasureQuality) ) |> Random.andThen (\minorTreasureNodeDistribution ->
                    ( distribution 2 (2 + (genLv // 4)) (TreasureNode MajorTreasureQuality) ) |> Random.andThen (\majorTreasureNodeDistribution ->
                    Random.constant
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
        
        monsterGeneratorM : Random.Generator Monster
        monsterGeneratorM =
            monsterGenerator |> Random.andThen (\ne ->
                Random.weighted
                    ( weightedToPair ne.head )
                    ( List.map weightedToPair ne.tail )
            )
        
        trapGeneratorM : Random.Generator Trap
        trapGeneratorM =
            trapGenerator |> Random.andThen (\ne ->
                Random.weighted
                    ( weightedToPair ne.head )
                    ( List.map weightedToPair ne.tail )
            )
        
        minorTreasureGenerator : Random.Generator Treasure
        minorTreasureGenerator =
            Random.Extra.andThen2 Random.weighted
                ( Random.constant ( 3, EmptyTreasure ) )
                ( Random.map List.concat <|
                  Random.Extra.sequence <|
                    [ treasurify 1 TrapTreasure trapGenerator
                    , goldTreasureGenerator 1
                    , treasurify 1 ItemTreasure itemGenerator
                    ]
                )
        
        majorTreasureGenerator : Random.Generator Treasure
        majorTreasureGenerator =
            Random.Extra.andThen2 Random.weighted
                ( Random.constant ( 0, EmptyTreasure ) )
                ( Random.map List.concat <|
                  Random.Extra.sequence <|
                    [ treasurify 1 TrapTreasure trapGenerator
                    , goldTreasureGenerator 3
                    , treasurify 3 ItemTreasure itemGenerator
                    , treasurify 1 WeaponTreasure weaponGenerator
                    , treasurify 1 ArmorTreasure armorGenerator
                    ]
                )
        goalTreasureGenerator : Random.Generator Treasure
        goalTreasureGenerator =
            Random.Extra.andThen2 Random.weighted
                ( Random.constant ( 0, EmptyTreasure ) )
                ( Random.map List.concat <|
                  Random.Extra.sequence <|
                    [ treasurify 1 WeaponTreasure weaponGenerator
                    , treasurify 1 ArmorTreasure armorGenerator
                    , treasurify 1 FurnitureTreasure furnitureGenerator
                    ]
                )
    in
    Random.map Map ( byLevel nameGenerator )
        |> Random.Extra.andMap levelGenerator
        |> Random.Extra.andMap ( byLevel depthGenerator )
        |> Random.Extra.andMap ( byLevel exploreNodeGeneratorGenerator )
        |> Random.Extra.andMap ( Random.constant monsterGeneratorM )
        |> Random.Extra.andMap ( Random.constant minorTreasureGenerator )
        |> Random.Extra.andMap ( Random.constant majorTreasureGenerator )
        |> Random.Extra.andMap ( Random.constant goalTreasureGenerator )
        |> Random.Extra.andMap ( Random.constant trapGeneratorM )

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
    , frequency : Frequency
    , name : String
    , hitPoints : Int
    , attack : Int
    , agility : Int
    , expYield : Int
    , goldYield : Int
    , poison : Int
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

newMonster : String -> Int -> Int -> Monster
newMonster name level hitPoints =
    { level = level
    , frequency = Common
    , name = name
    , hitPoints = hitPoints
    , attack = 0
    , agility = 0
    , expYield = 0
    , goldYield = 0
    , poison = 0
    }

nullMonster : Monster
nullMonster =
    newMonster "Null Monster" 0 0

bossSlime : Monster
bossSlime =
    { level = 2
    , frequency = Legendary
    , name = "Boss Slime"
    , hitPoints = 2
    , attack = 8
    , agility = 1
    , expYield = 10
    , goldYield = 10
    , poison = 0
    }

allMonsters =
    [ let m = newMonster "Slime" 1 1 in { m | attack = 1, expYield = 1, goldYield = 1 }
    , let m = newMonster "Beastie" 1 2 in { m | attack = 2, expYield = 2, goldYield = 1 }
    , let m = newMonster "Owl" 1 2 in { m | frequency = Uncommon, attack = 1, expYield = 1, goldYield = 2 }
    , let m = newMonster "Snake" 2 1 in { m | attack = 1, expYield = 2, goldYield = 2, poison = 1 }
    , let m = newMonster "Wolf" 2 3 in { m | attack = 3, expYield = 3, goldYield = 3 }
    , let m = newMonster "Bear" 3 5 in { m | attack = 7, expYield = 6, goldYield = 6 }
    ]

-- ITEM

type alias Item =
    { name : String
    , level : Int
    , price : Int
    , context : Context
    , frequency : Frequency
    , healAmount : Int
    , escapeFromDungeon : Bool
    , antidoteAmount : Int
    , damage : Int
    }

newItem : String -> Int -> Int -> Context -> Item
newItem name level price context =
    { name = name
    , level = level
    , price = price
    , context = context
    , frequency = Common
    , healAmount = 0
    , escapeFromDungeon = False
    , antidoteAmount = 0
    , damage = 0
    }

nullItem : Item
nullItem =
    newItem "Null Item" 0 0 AnyContext

allItems : List Item
allItems =
    [ let i = newItem "Buttermilk Old-Fashioned Donut" 1 1 AnyContext in { i | healAmount = 1}
    , let i = newItem "Antidote" 1 1 AnyContext in { i | antidoteAmount = 1 }
    , let i = newItem "Escape Rope" 1 1 ExploreContext in { i | escapeFromDungeon = True }
    , let i = newItem "Dart" 1 1 BattleContext in { i | damage = 1 }
    ]

-- WEAPON

type alias Weapon =
    { name : String
    , level : Int
    , price : Int
    , frequency : Frequency
    , attackBonus : Int
    }

newWeapon : String -> Int -> Int -> Weapon
newWeapon name level price =
    { name = name
    , level = level
    , price = price
    , frequency = Common
    , attackBonus = 0
    }

nullWeapon : Weapon
nullWeapon =
    newWeapon "Null Weapon" 0 0

allWeapons : List Weapon
allWeapons =
    [ let w = newWeapon "Copper Knife" 1 1 in { w | attackBonus = 1 }
    , let w = newWeapon "Stone Axe" 1 1 in { w | attackBonus = 3, frequency = Uncommon }
    ]

-- ARMOR

type alias Armor =
    { name : String
    , level : Int
    , price : Int
    , frequency : Frequency
    , defenseBonus : Int
    }

newArmor : String -> Int -> Int -> Armor
newArmor name level price =
    { name = name
    , level = level
    , price = price
    , frequency = Common
    , defenseBonus = 0
    }

nullArmor : Armor
nullArmor =
    newArmor "Null Armor" 0 0

allArmors : List Armor
allArmors =
    [ let a = newArmor "Leather Armor" 1 1 in { a | defenseBonus = 1 }
    ]

-- FURNITURE

type alias Furniture =
    { name : String
    , level : Int
    , price : Int
    , frequency : Frequency
    , healAmount : Int
    }

newFurniture : String -> Int -> Int -> Furniture
newFurniture name level price =
    { name = name
    , level = level
    , price = price
    , frequency = Common
    , healAmount = 0
    }

nullFurniture : Furniture
nullFurniture =
    newFurniture "Null Furniture" 0 0

allFurniture : List Furniture
allFurniture =
    [ let f = newFurniture "Heal Pillow" 1 1 in { f | healAmount = 1 }
    ]

-- OBJECT

type Object
    = ItemObject Item
    | WeaponObject Weapon
    | ArmorObject Armor
    | FurnitureObject Furniture

allObjects : List Object
allObjects =
    List.concat
        [ List.map ItemObject allItems
        , List.map WeaponObject allWeapons
        , List.map ArmorObject allArmors
        , List.map FurnitureObject allFurniture
        ]

-- TREASURE

type Treasure
    = TrapTreasure Trap
    | EmptyTreasure
    | GoldTreasure Int
    | ItemTreasure Item
    | WeaponTreasure Weapon
    | ArmorTreasure Armor
    | FurnitureTreasure Furniture

allTreasures : List Treasure
allTreasures =
    List.concat
        [ List.map TrapTreasure allTraps
        , [ EmptyTreasure ]
        , [ GoldTreasure 1 ]
        , List.map ItemTreasure allItems
        , List.map WeaponTreasure allWeapons
        , List.map ArmorTreasure allArmors
        ]

type alias Skill =
    { name : String
    , learnCost : Int
    , mpCost : Int
    , context : Context
    , forestWalkEffect : Bool
    , damage : Int
    }

type Context
    = AnyContext
    | ExploreContext
    | BattleContext

newSkill : String -> Int -> Int -> Context -> Skill
newSkill name learnCost mpCost skillContext =
    { name = name
    , learnCost = learnCost
    , mpCost = mpCost
    , context = skillContext
    , forestWalkEffect = False
    , damage = 0
    }

allSkills : List Skill
allSkills =
    [ let s = newSkill "Forest Walk" 1 1 ExploreContext in { s | forestWalkEffect = True }
    , let s = newSkill "Fire" 1 1 BattleContext in { s | damage = 1 }
    ]

-- PASSIVE

type alias Passive =
    { name : String
    , learnCost : Int
    , maxHitPointBonus : Int
    , maxMagicPointBonus : Int
    , attackBonus : Int
    , defenseBonus : Int
    , agilityBonus : Int
    }

newPassive : String -> Int -> Passive
newPassive name learnCost =
    { name = name
    , learnCost = learnCost
    , maxHitPointBonus = 0
    , maxMagicPointBonus = 0
    , attackBonus = 0
    , defenseBonus = 0
    , agilityBonus = 0
    }

allPassives : List Passive
allPassives =
    [ let p = newPassive "HP +2" 1 in { p | maxHitPointBonus = 2 }
    , let p = newPassive "ATK +1" 1 in { p | attackBonus = 1 }
    , let p = newPassive "DEF +1" 1 in { p | defenseBonus = 1 }
    , let p = newPassive "AGI +1" 1 in { p | agilityBonus = 1 }
    ]

-- TRAP

type alias Trap =
    { name : String
    , level : Int
    , frequency : Frequency
    , damage : Int
    , poison : Int
    }

newTrap : String -> Int -> Trap
newTrap name level =
    { name = name
    , level = level
    , frequency = Common
    , damage = 0
    , poison = 0
    }

nullTrap : Trap
nullTrap =
    newTrap "Null Trap" 0

allTraps : List Trap
allTraps =
    [ let t = newTrap "Arrow Trap" 3 in { t | damage = 1 }
    , let t = newTrap "Poison Trap" 3 in { t | poison = 1 }
    ]

-- MAIN

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
            , class = Commoner
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
            , skills = []
            , passives = []
            , encounteredMonster = Nothing
            , messages = []
            , activeSkills = []
            , depth = 0
            , maps = []
            , currentMap = Nothing
            , poison = 0
            , residence = "Hostel"
            , furniture = []
            , encounteredTrap = Nothing
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
        , Html.li [] [ Html.text <| "Class: " ++ classToString model.class ]
        , Html.li [] [ Html.text <| "Level: " ++ String.fromInt model.level ]
        , Html.li [] [ Html.text <| "EXP: " ++ String.fromInt model.experience ++ " / " ++ String.fromInt model.totalExperience ++ " / " ++ String.fromInt (model.level * model.level * 10) ]
        , Html.li [] [ Html.text <| "HP: " ++ String.fromInt model.hitPoints ++ " / " ++ String.fromInt model.maxHitPoints ]
        , ( if model.poison > 0 then
                Html.li [] [ Html.text <| "Poison: " ++ String.fromInt model.poison ]
            else
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
                ( List.map (\item -> Html.button [ Html.Events.onClick (UseItem item) ] [ Html.text item.name ]) model.inventory )
            ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Furniture: " ]
            , Html.ul 
                []
                ( List.map (\furniture -> Html.button [] [ Html.text furniture.name ]) model.furniture )
            ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Weapons: " ]
            , Html.ul 
                []
                ( List.map (\weapon -> Html.button [ Html.Events.onClick <| EquipWeapon weapon ] [ Html.text weapon.name ]) model.weapons )
            ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Equipped Weapon: " ]
            , Html.ul 
                []
                [ Html.button (equippedWeaponActions model.equippedWeapon) [ Html.text <| Maybe.withDefault "Nothing" (Maybe.map .name model.equippedWeapon) ] ]
            ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Armor: " ]
            , Html.ul 
                []
                ( List.map (\armor -> Html.button [ Html.Events.onClick <| EquipArmor armor ] [ Html.text armor.name ]) model.armors )
            ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Equipped Armor: " ]
            , Html.ul 
                []
                [ Html.button (equippedArmorActions model.equippedArmor) [ Html.text <| Maybe.withDefault "Nothing" (Maybe.map .name model.equippedArmor) ] ]
            ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Skills: " ]
            , Html.ul 
                []
                ( List.map (\skill -> Html.button [ Html.Events.onClick <| UseSkill skill ] [ Html.text skill.name ]) model.skills )
            ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Passive: " ]
            , Html.ul 
                []
                ( List.map (\passive -> Html.button [] [ Html.text passive.name ]) model.passives )
            ]
        , Html.li [] 
            [ Html.li [] [ Html.text <| "Active Skills: " ]
            , Html.ul 
                []
                ( List.map (\skill -> Html.li [] [ Html.text skill.name ]) (model.activeSkills) )
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
                    if List.any .forestWalkEffect model.activeSkills then
                        [ viewOption Leave "Leave"
                        , viewOption Continue "Continue"
                        ]
                    else
                        [ viewOption Leave "Leave"
                        ]
                
                TrapNode ->
                    [ case model.encounteredTrap of
                        Just trap ->
                            Html.ul []
                                [ Html.li [] [ Html.text <| "Name: " ++ trap.name ]
                                , Html.li [] [ Html.text <| "Level: " ++ String.fromInt trap.level ]
                                , Html.li [] [ Html.text <| "Damage: " ++ String.fromInt trap.damage ]
                                , if trap.poison > 0 then
                                    Html.li [] [ Html.text <| "Poison: " ++ String.fromInt trap.poison ]
                                  else
                                    Html.node "blank" [] []
                                , viewOption (SpringTrap trap) "Spring Trap"
                                ]
                        Nothing ->
                            Html.node "blank" [] []
                    
                    , viewOption Leave "Leave"
                    ]
                
                MonsterNode ->
                    [ case model.encounteredMonster of
                        Just monster ->
                            Html.ul []
                                [ Html.li [] [ Html.text <| "Name: " ++ monster.name ]
                                , Html.li [] [ Html.text <| "Hit Points: " ++ String.fromInt monster.hitPoints ]
                                , Html.li [] [ Html.text <| "Attack: " ++ String.fromInt monster.attack ]
                                , if monster.poison > 0 then
                                        Html.li [] [ Html.text <| "Poison: " ++ String.fromInt monster.poison ]
                                  else
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
        (
        [ Html.li [] [ Html.button [ Html.Events.onClick Inn ] [ Html.text <| "Rest" ] ]
        , Html.li []
            ( List.map (\map -> Html.button [ Html.Events.onClick <| Explore map ] [ Html.text <| "Explore: " ++ map.name ]) model.maps )
        , Html.li [] [ Html.button [ Html.Events.onClick (BossFight bossSlime) ] [ Html.text <| "Fight Boss Slime" ] ]
        , Html.li [] [ Html.button [ Html.Events.onClick DoWork ] [ Html.text <| "Do Work" ] ]
        ]
        ++ (List.map (\item -> Html.li [] [ Html.button [ Html.Events.onClick <| BuyItem item ] [ Html.text <| "Buy: " ++ item.name ++ " (" ++ String.fromInt item.price ++ " G)" ] ]) allItems)
        ++ (List.map (\furniture -> Html.li [] [ Html.button [ Html.Events.onClick <| BuyFurniture furniture ] [ Html.text <| "Buy: " ++ furniture.name ++ " (" ++ String.fromInt furniture.price ++ " G)" ] ]) allFurniture)
        ++ (List.map (\weapon -> Html.li [] [ Html.button [ Html.Events.onClick <| BuyWeapon weapon ] [ Html.text <| "Buy: " ++ weapon.name ++ " (" ++ String.fromInt weapon.price ++ " G)" ] ]) allWeapons)
        ++ (List.map (\armor -> Html.li [] [ Html.button [ Html.Events.onClick <| BuyArmor armor ] [ Html.text <| "Buy: " ++ armor.name ++ " (" ++ String.fromInt armor.price ++ " G)" ] ]) allArmors)
        ++ (List.map (\skill -> Html.li [] [ Html.button [ Html.Events.onClick <| LearnSkill skill ] [ Html.text <| "Learn: " ++ skill.name ++ " (" ++ String.fromInt skill.learnCost ++ " EXP)" ] ]) allSkills)
        ++ (List.map (\passive -> Html.li [] [ Html.button [ Html.Events.onClick <| LearnPassive passive ] [ Html.text <| "Learn: " ++ passive.name ++ " (" ++ String.fromInt passive.learnCost ++ " EXP)" ] ]) allPassives)
        ++ (List.map (\class -> Html.li [] [ Html.button [ Html.Events.onClick <| ChangeClass class ] [ Html.text <| "Change Class: " ++ classToString class ] ])  allClasses )
        )

equippedWeaponActions : Maybe Weapon -> List (Html.Attribute Msg)
equippedWeaponActions m =
    case m of
        Nothing -> 
            []
        
        Just w -> 
            [ Html.Events.onClick <| UnEquipWeapon w ]

equippedArmorActions : Maybe Armor -> List (Html.Attribute Msg)
equippedArmorActions m =
    case m of
        Nothing -> 
            []
        
        Just a -> 
            [ Html.Events.onClick <| UnEquipArmor a ]

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
    case ( msg, model.mode ) of
        ( Inn, NotExploring ) ->
            updateInn model
        
        ( Explore map, NotExploring ) ->
            updateExplore map model
        
        ( SpringTrap trap, Exploring _ ) ->
            updateSpringTrap trap model
        
        ( Fight, Exploring MonsterNode ) ->
            updateFight model
        
        ( BossFight monster, NotExploring ) ->
            updateBossFight monster model
        
        ( Flee, Exploring MonsterNode ) ->
            updateFlee model
        
        ( BuyItem item, NotExploring ) ->
            updateBuyItem item model
        
        ( BuyWeapon weapon, NotExploring ) ->
            updateBuyWeapon weapon model
        
        ( EquipWeapon weapon, _ ) ->
            updateEquipWeapon weapon model
        
        ( UnEquipWeapon weapon, _ ) ->
            updateUnEquipWeapon weapon model
        
        ( UseItem item, _ ) ->
            updateUseItem item model
        
        ( SavePoint, Exploring SavePointNode ) ->
            updateSavePoint model
        
        ( LearnSkill skill, _ ) ->
            updateLearnSkill skill model
        
        ( LearnPassive passive, _ ) ->
            updateLearnPassive passive model
        
        ( UseSkill skill, _ ) ->
            updateUseSkill skill model
        
        ( BuyArmor armor, NotExploring ) ->
            updateBuyArmor armor model
        
        ( EquipArmor armor, _ ) ->
            updateEquipArmor armor model
        
        ( UnEquipArmor armor, _ ) ->
            updateUnEquipArmor armor model
        
        ( GenerateTreasure distribution, _ ) ->
            updateGenerateTreasure distribution model
        
        ( GetTreasure treasure, Exploring GoalNode ) ->
            updateGetTreasure False treasure model
        
        ( GetTreasure treasure, Exploring _ ) ->
            updateGetTreasure True treasure model
        
        ( GetTreasure treasure, _ ) ->
            updateGetTreasure False treasure model
        
        ( GetMonster monster, Exploring MonsterNode ) ->
            updateGetMonster monster model
        
        ( GetTrap trap, Exploring TrapNode ) ->
            updateGetTrap trap model
        
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
        
        ( ChangeClass class, _ ) ->
            updateChangeClass class model
        
        ( BuyFurniture furniture, _ ) ->
            updateBuyFurniture furniture model
        
        _ ->
            ( model, Cmd.none )

updateInn : Model -> ( Model, Cmd Msg )
updateInn model =
    let 
        healFromRest =
            model.furniture
                |> List.map .healAmount
                |> List.sum
        
        newModel =
            { model
                | day = model.day + 1
                , time = model.maxTime
                , hitPoints = min (model.hitPoints + healFromRest) model.maxHitPoints
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
                , activeSkills = []
                , depth = 0
                , currentMap = Just map
            }
    in
    ( newModel, nextCmd )

updateSpringTrap : Trap -> Model -> ( Model, Cmd Msg )
updateSpringTrap trap model =
    let 
        newModel =
            if model.agility < trap.level then
                { model
                    | hitPoints = max (model.hitPoints - trap.damage) 0
                    , poison = max (model.poison - trap.poison) 0
                    , encounteredTrap = Nothing
                }
            else
                model
    in
    ( newModel, getNextExploreNode model.currentMap )

updateBossFight : Monster -> Model -> ( Model, Cmd Msg )
updateBossFight monster model =
    let
        damage = max (monster.attack - model.defense) 0
        win = model.attack >= monster.hitPoints
        goldGain = if win then monster.goldYield else 0
        expGainer = if win then updateExpGain monster.expYield else \m -> m 
        
        newModel =
            { model
                | hitPoints = max (model.hitPoints - damage) 0
                , gold = model.gold + goldGain
                , poison = model.poison + monster.poison
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
                        win = model.attack >= monster.hitPoints
                        goldGain = if win then monster.goldYield else 0
                        expGainer = if win then updateExpGain monster.expYield else \m -> m
                    in
                    { model
                        | hitPoints = max (model.hitPoints - damage) 0
                        , gold = model.gold + goldGain
                        , encounteredMonster = Nothing
                        , poison = model.poison + monster.poison
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
                        , activeSkills = []
                        , currentMap = Nothing
                    }
                
                Nothing ->
                    model
    in
    ( newModel, Cmd.none )

updateBuyItem : Item -> Model -> ( Model, Cmd Msg )
updateBuyItem item model =
    let
        paid = if model.gold >= item.price then item.price else 0
        newItems = if model.gold >= item.price then [ item ] else []
        newModel =
            { model
                | inventory = List.append newItems model.inventory
                , gold = model.gold - paid
            }
    in
    ( newModel, Cmd.none )

updateBuyWeapon : Weapon -> Model -> ( Model, Cmd Msg )
updateBuyWeapon weapon model =
    let
        paid = if model.gold >= weapon.price then weapon.price else 0
        newWeapons = if model.gold >= weapon.price then [ weapon ] else []
        newModel =
            { model
                | weapons = List.append newWeapons model.weapons
                , gold = model.gold - paid
            }
    in
    ( newModel, Cmd.none )

updateUseItem : Item -> Model -> ( Model, Cmd Msg )
updateUseItem item model =
    let
        ( newModel, newCmd ) =
            case ( item.context, model.mode ) of
                ( AnyContext, _ ) ->
                    let
                        nextModel =
                            model
                    in
                    ( nextModel, Cmd.none )
                
                ( ExploreContext, Exploring _ ) ->
                    let
                        nextMode =
                            if item.escapeFromDungeon then NotExploring else model.mode
                        nextModel =
                            { model
                                | mode = nextMode
                            }
                    in
                    ( nextModel, Cmd.none )
                
                ( BattleContext, Exploring MonsterNode ) ->
                    case model.encounteredMonster of
                        Just monster ->
                            let
                                win =
                                    monster.hitPoints <= item.damage
                                goldGain = if win then monster.goldYield else 0
                                expGainer = if win then updateExpGain monster.expYield else \m -> m
                                nextMonster =
                                    if win then
                                        Nothing
                                    else
                                        Just { monster | hitPoints = max (monster.hitPoints - item.damage) 0 }
                                nextModel =
                                    { model
                                        | encounteredMonster = nextMonster
                                        , gold = model.gold + goldGain
                                    }
                                        |> expGainer
                                nextCmd =
                                    if win then getNextExploreNode model.currentMap else Cmd.none
                            in
                            ( nextModel, nextCmd )
                            
                        Nothing ->
                            ( model, Cmd.none )
                
                _ ->
                    ( model, Cmd.none )
    
        newModel2 =
            { newModel
                | inventory = Maybe.withDefault [] (List.tail newModel.inventory)
                , hitPoints = min (newModel.hitPoints + item.healAmount) newModel.maxHitPoints
                , poison = max (newModel.poison - item.antidoteAmount) 0
            }
    in
    ( newModel2, newCmd )

updateEquipWeapon : Weapon -> Model -> ( Model, Cmd Msg )
updateEquipWeapon weapon model =
    let
        newModel =
            { model
                | weapons = Maybe.withDefault [] (List.tail model.weapons)
                , equippedWeapon = Just weapon
                , attack = model.attack + weapon.attackBonus
            }
    in
    ( newModel, Cmd.none )

updateUnEquipWeapon : Weapon -> Model -> ( Model, Cmd Msg )
updateUnEquipWeapon weapon model =
    let
        newModel =
            { model
                | weapons = weapon :: model.weapons
                , equippedWeapon = Nothing
                , attack = model.attack - weapon.attackBonus
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

updateLearnSkill : Skill -> Model -> ( Model, Cmd Msg )
updateLearnSkill skill model =
    let
        condition = model.experience >= skill.learnCost
        expPaid = if condition then skill.learnCost else 0
        newSkills =
            if condition then
                skill :: model.skills
            else
                model.skills
        newModel =
            { model
                | skills = newSkills
                , experience = model.experience - expPaid
            }
    in
    ( newModel, Cmd.none )

updateLearnPassive : Passive -> Model -> ( Model, Cmd Msg )
updateLearnPassive passive model =
    let
        newModel =
            if model.experience >= passive.learnCost then
                { model
                    | passives = passive :: model.passives
                    , experience = model.experience - passive.learnCost
                    , maxHitPoints = model.maxHitPoints + passive.maxHitPointBonus
                    , maxMagicPoints = model.maxMagicPoints + passive.maxMagicPointBonus
                    , attack = model.attack + passive.attackBonus
                    , defense = model.defense + passive.defenseBonus
                    , agility = model.agility + passive.agilityBonus
                }
            else
                model
    in
    ( newModel, Cmd.none )

updateUseSkill : Skill -> Model -> ( Model, Cmd Msg )
updateUseSkill skill model =
    let
        condition = model.magicPoints >= skill.mpCost
        magicCost = if condition then skill.mpCost else 0
        ( newModel, newCmd ) =
            if condition then
                case ( skill.context, model.mode ) of
                    ( AnyContext, _ ) ->
                        let
                            nextModel =
                                { model
                                    | magicPoints = model.magicPoints - skill.mpCost
                                }
                        in
                        ( nextModel, Cmd.none )
                    
                    ( ExploreContext, Exploring _ ) ->
                        let
                            nextModel =
                                { model
                                    | activeSkills = skill :: model.activeSkills
                                    , magicPoints = model.magicPoints - skill.mpCost
                                }
                        in
                        ( nextModel, Cmd.none )
                    
                    ( BattleContext, Exploring MonsterNode ) ->
                        case model.encounteredMonster of
                            Just monster ->
                                let
                                    win =
                                        monster.hitPoints <= skill.damage
                                    goldGain = if win then monster.goldYield else 0
                                    expGainer = if win then updateExpGain monster.expYield else \m -> m
                                    nextMonster =
                                        if win then
                                            Nothing
                                        else
                                            Just { monster | hitPoints = max (monster.hitPoints - skill.damage) 0 }
                                    nextModel =
                                        { model
                                            | encounteredMonster = nextMonster
                                            , gold = model.gold + goldGain
                                        }
                                            |> expGainer
                                    nextCmd =
                                        if win then getNextExploreNode model.currentMap else Cmd.none
                                in
                                ( nextModel, nextCmd )
                                
                            Nothing ->
                                ( model, Cmd.none )
                    
                    _ ->
                        ( model, Cmd.none )
            else
                ( model, Cmd.none )
    in
    ( newModel, newCmd )
                     
updateBuyArmor : Armor -> Model -> ( Model, Cmd Msg )
updateBuyArmor armor model =
    let
        paid = if model.gold >= armor.price then armor.price else 0
        newArmors = if model.gold >= armor.price then [ armor ] else []
        newModel =
            { model
                | armors = List.append newArmors model.armors
                , gold = model.gold - paid
            }
    in
    ( newModel, Cmd.none )

updateEquipArmor : Armor -> Model -> ( Model, Cmd Msg )
updateEquipArmor armor model =
    let
        newModel =
            { model
                | armors = Maybe.withDefault [] (List.tail model.armors)
                , equippedArmor = Just armor
                , defense = model.defense + armor.defenseBonus
            }
    in
    ( newModel, Cmd.none )

updateUnEquipArmor : Armor -> Model -> ( Model, Cmd Msg )
updateUnEquipArmor armor model =
    let
        newModel =
            { model
                | armors = armor :: model.armors
                , equippedArmor = Nothing
                , defense = model.defense - armor.defenseBonus
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
                TrapTreasure trap ->
                    let
                        ( model2, _ ) = updateSpringTrap trap model
                    in
                    model2
                
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
                
                FurnitureTreasure furniture ->
                    { model | furniture = furniture :: model.furniture }
    in
    ( newModel, nextCmd )

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
                , activeSkills = []
                , currentMap = Nothing
                , encounteredTrap = Nothing
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
        hpLossFromPoison = model.poison
        maxDepth =
            model.currentMap
                |> Maybe.map .depth
                |> Maybe.withDefault 0
        
        nextExploreNode =
            if model.depth >= maxDepth then GoalNode else exploreNode
        
        monsterGenerator =
            model.currentMap
                |> Maybe.map .monsterGenerator
                |> Maybe.withDefault ( Random.constant nullMonster )
        
        trapGenerator =
            model.currentMap
                |> Maybe.map .trapGenerator
                |> Maybe.withDefault ( Random.constant nullTrap )
        
        newCmd =
            case nextExploreNode of
                MonsterNode ->
                    Random.generate GetMonster monsterGenerator
                
                TrapNode ->
                    Random.generate GetTrap trapGenerator
                
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
                    if List.any (\s -> s.forestWalkEffect) model.activeSkills then
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

updateGetTrap : Trap -> Model -> ( Model, Cmd Msg )
updateGetTrap trap model =
    let
        newModel =
            { model
                | encounteredTrap = Just trap
            }
    in
    ( newModel, Cmd.none )

updateChangeClass : Class -> Model -> ( Model, Cmd Msg )
updateChangeClass class model =
    let
        newModel =
            { model
                | class = class
            }
    in
    ( newModel, Cmd.none )

updateBuyFurniture : Furniture -> Model -> ( Model, Cmd Msg )
updateBuyFurniture furniture model =
    let
        condition = model.gold >= furniture.price
        newModel =
            if condition then
                { model
                    | gold = model.gold - furniture.price
                    , furniture = furniture :: model.furniture
                }
            else
                model
    in
    ( newModel, Cmd.none )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none