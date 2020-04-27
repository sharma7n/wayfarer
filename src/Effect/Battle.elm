module Effect.Battle exposing
    ( Effect(..)
    , toString
    )


type Effect
    = ChangeActionPoints Int
    | ChangeGeneratedBlock Int
    | ChangeMonsterHitPoints Int
    | DealDamage Int


toString : Effect -> String
toString effect =
    case effect of
        ChangeActionPoints delta ->
            "AP " ++ String.fromInt delta

        ChangeGeneratedBlock delta ->
            "Block " ++ String.fromInt delta

        ChangeMonsterHitPoints delta ->
            "Deal " ++ String.fromInt delta

        DealDamage damage ->
            "Damage " ++ String.fromInt damage
