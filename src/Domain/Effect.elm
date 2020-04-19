module Domain.Effect exposing
    ( BattleEffect(..)
    , DungeonEffect(..)
    , Effect(..)
    , GlobalEffect(..)
    , HomeEffect(..)
    )


type Effect
    = Global GlobalEffect
    | Home HomeEffect
    | Dungeon DungeonEffect
    | Battle BattleEffect


type GlobalEffect
    = ChangeHitPoints Int
    | ChangeGold Int


type HomeEffect
    = ChangeTime Int


type DungeonEffect
    = ChangeSafety Int
    | ChangePath Int


type BattleEffect
    = ChangeActionPoints Int
    | GenerateBlock Int
    | DealDamage Int
