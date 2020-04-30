module Domain.Plant exposing
    ( LifecycleStage(..)
    , Plant
    )


type LifecycleStage
    = Seed
    | Sprout
    | Growth
    | Flower
    | Fruit


type alias Plant =
    { name : String
    , lifecycleStage : LifecycleStage
    , experience : Int
    , hitPoints : Int
    }


cata : a -> a -> a -> a -> a -> LifecycleStage -> a
cata seedF sproutF growthF flowerF fruitF stage =
    case stage of
        Seed ->
            seedF

        Sprout ->
            sproutF

        Growth ->
            growthF

        Flower ->
            flowerF

        Fruit ->
            fruitF


experienceToNextStage : LifecycleStage -> Maybe Int
experienceToNextStage stage =
    stage
        |> cata (Just 10) (Just 30) (Just 60) (Just 100) Nothing
