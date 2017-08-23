module VirtualDom.Events
    exposing
        ( on
        , onBoolValueChanged
        , onFloatValueChanged
        , onTouchUpInside
        , onTouchUpOutside
        , onTouchDown
        , onTouchDownRepeat
        , onTouchCancel
        , onTouchDragInside
        , onTouchDragOutside
        , onTouchDragEnter
        , onTouchDragExit
        , onAllTouchEvents
        )

{-| #Events
@docs on, onBoolValueChanged, onFloatValueChanged, onTouchUpInside, onTouchUpOutside, onTouchDown, onTouchDownRepeat, onTouchCancel, onTouchDragInside, onTouchDragOutside, onTouchDragEnter, onTouchDragExit, onAllTouchEvents, on
-}

import VirtualDom
import VirtualDom.Element exposing (Attribute)
import Json.Decode as Json


{-| -}
on : String -> Json.Decoder msg -> Attribute msg
on =
    VirtualDom.on



-- TODO valueChanged


{-| -}
onBoolValueChanged : (Bool -> msg) -> Attribute msg
onBoolValueChanged tagger =
    on "valueChanged" (Json.map tagger Json.bool)


{-| -}
onFloatValueChanged : (Float -> msg) -> Attribute msg
onFloatValueChanged tagger =
    on "valueChanged" (Json.map tagger Json.float)


{-| -}
onTouchUpInside : msg -> Attribute msg
onTouchUpInside msg =
    on "touchUpInside" (Json.succeed msg)


{-| -}
onTouchUpOutside : msg -> Attribute msg
onTouchUpOutside msg =
    on "touchUpOutside" (Json.succeed msg)


{-| -}
onTouchDown : msg -> Attribute msg
onTouchDown msg =
    on "touchDown" (Json.succeed msg)


{-| -}
onTouchDownRepeat : msg -> Attribute msg
onTouchDownRepeat msg =
    on "touchDownRepeat" (Json.succeed msg)


{-| -}
onTouchCancel : msg -> Attribute msg
onTouchCancel msg =
    on "touchCancel" (Json.succeed msg)


{-| -}
onTouchDragInside : msg -> Attribute msg
onTouchDragInside msg =
    on "touchDragInside" (Json.succeed msg)


{-| -}
onTouchDragOutside : msg -> Attribute msg
onTouchDragOutside msg =
    on "touchDragOutside" (Json.succeed msg)


{-| -}
onTouchDragEnter : msg -> Attribute msg
onTouchDragEnter msg =
    on "touchDragEnter" (Json.succeed msg)


{-| -}
onTouchDragExit : msg -> Attribute msg
onTouchDragExit msg =
    on "touchDragExit" (Json.succeed msg)


{-| -}
onAllTouchEvents : msg -> Attribute msg
onAllTouchEvents msg =
    on "allTouchEvents" (Json.succeed msg)
