module Element.Internal
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

import Json.Decode as Json
import Native.Element


type Node msg
    = Node


parent : List (Property msg) -> List (Node msg) -> Node msg
parent =
    Native.Element.parent


leaf : String -> List (Property msg) -> Node msg
leaf =
    Native.Element.leaf


map : (a -> msg) -> Node a -> Node msg
map =
    Native.Element.map


type Property msg
    = Property


property : String -> Json.Value -> Property msg
property =
    Native.Element.property


yogaProperty : String -> Json.Value -> Property msg
yogaProperty =
    Native.Element.yogaProperty


mapProperty : (a -> b) -> Property a -> Property b
mapProperty =
    Native.Element.mapProperty


on : String -> Json.Decoder msg -> Property msg
on =
    Native.Element.on


lazy : (a -> Node msg) -> a -> Node msg
lazy =
    Native.Element.lazy


lazy2 : (a -> b -> Node msg) -> a -> b -> Node msg
lazy2 =
    Native.Element.lazy2


lazy3 : (a -> b -> c -> Node msg) -> a -> b -> c -> Node msg
lazy3 =
    Native.Element.lazy3


program :
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : model -> Node msg
    }
    -> Program Never model msg
program =
    Native.Element.program
