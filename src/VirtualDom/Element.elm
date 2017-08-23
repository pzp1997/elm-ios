module VirtualDom.Element
    exposing
        ( Element
        , Attribute
        , label
        , image
        , button
        , slider
        , switch
        , column
        , row
        , map
        , beginnerProgram
        , program
        )

{-| #Element
@docs Element, Attribute, label, image, button, slider, switch, column, row, map, beginnerProgram, program
-}

import VirtualDom
import Json.Encode as Json


{-| -}
type alias Element msg =
    VirtualDom.Node msg


{-| -}
type alias Attribute msg =
    VirtualDom.Property msg


{-| -}
label : List (Attribute msg) -> Element msg
label properties =
    VirtualDom.leaf "label" properties


{-| -}
image : List (Attribute msg) -> Element msg
image properties =
    VirtualDom.leaf "image" properties


{-| -}
button : List (Attribute msg) -> Element msg
button properties =
    VirtualDom.leaf "button" properties


{-| -}
slider : List (Attribute msg) -> Element msg
slider properties =
    VirtualDom.leaf "slider" properties


{-| -}
switch : List (Attribute msg) -> Element msg
switch properties =
    VirtualDom.leaf "switch" properties


{-| -}
column : List (Attribute msg) -> List (Element msg) -> Element msg
column properties children =
    VirtualDom.parent
        (VirtualDom.yogaProperty "flexDirection" (Json.string "column")
            :: properties
        )
        children


{-| -}
row : List (Attribute msg) -> List (Element msg) -> Element msg
row properties children =
    VirtualDom.parent
        (VirtualDom.yogaProperty "flexDirection" (Json.string "row")
            :: properties
        )
        children


{-| -}
map : (a -> msg) -> Element a -> Element msg
map =
    VirtualDom.map


{-| -}
beginnerProgram :
    { model : model
    , view : model -> Element msg
    , update : msg -> model -> model
    }
    -> Program Never model msg
beginnerProgram { model, view, update } =
    program
        { init = model ! []
        , update = \msg model -> update msg model ! []
        , view = view
        , subscriptions = \_ -> Sub.none
        }


{-| -}
program :
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : model -> Element msg
    }
    -> Program Never model msg
program =
    VirtualDom.program
