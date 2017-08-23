module VirtualDom
    exposing
        ( Node
        , leaf
        , parent
        , map
        , Property
        , property
        , yogaProperty
        , mapProperty
        , on
        , lazy
        , lazy2
        , lazy3
        , program
        )

{-| #VirtualDom
@docs Node, leaf, map, parent, Property, property, yogaProperty, mapProperty, on, lazy, lazy2, lazy3, program
-}

import Json.Decode as Json
import Native.VirtualDom


{-| -}
type Node msg
    = Node


{-| -}
parent : List (Property msg) -> List (Node msg) -> Node msg
parent =
    Native.VirtualDom.parent


{-| -}
leaf : String -> List (Property msg) -> Node msg
leaf =
    Native.VirtualDom.leaf


{-| -}
map : (a -> msg) -> Node a -> Node msg
map =
    Native.VirtualDom.map


{-| -}
type Property msg
    = Property


{-| -}
property : String -> Json.Value -> Property msg
property =
    Native.VirtualDom.property


{-| -}
yogaProperty : String -> Json.Value -> Property msg
yogaProperty =
    Native.VirtualDom.yogaProperty


{-| -}
mapProperty : (a -> b) -> Property a -> Property b
mapProperty =
    Native.VirtualDom.mapProperty


{-| -}
on : String -> Json.Decoder msg -> Property msg
on =
    Native.VirtualDom.on


{-| -}
lazy : (a -> Node msg) -> a -> Node msg
lazy =
    Native.VirtualDom.lazy


{-| -}
lazy2 : (a -> b -> Node msg) -> a -> b -> Node msg
lazy2 =
    Native.VirtualDom.lazy2


{-| -}
lazy3 : (a -> b -> c -> Node msg) -> a -> b -> c -> Node msg
lazy3 =
    Native.VirtualDom.lazy3


{-| -}
program :
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : model -> Node msg
    }
    -> Program Never model msg
program =
    Native.VirtualDom.program
