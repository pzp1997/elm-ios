module Element
    exposing
        ( Element
        , Attribute
        , label
        , image
        , button
          -- , slider
          -- , switch
        , column
        , row
        , map
        , beginnerProgram
        , program
        )

{-| #Element
@docs Element, Attribute, label, image, button, column, row, map, beginnerProgram, program
-}

import Element.Internal as Internal
import Json.Encode as Json


{-| -}
type alias Element msg =
    Internal.Node msg


{-| -}
type alias Attribute msg =
    Internal.Property msg


{-| -}
label : List (Attribute msg) -> Element msg
label properties =
    Internal.leaf "label" properties


{-| -}
image : List (Attribute msg) -> Element msg
image properties =
    Internal.leaf "image" properties


{-| -}
button : List (Attribute msg) -> Element msg
button properties =
    Internal.leaf "button" properties


{-| -}
slider : List (Attribute msg) -> Element msg
slider properties =
    Internal.leaf "slider" properties


{-| -}
switch : List (Attribute msg) -> Element msg
switch properties =
    Internal.leaf "switch" properties


{-| -}
column : List (Attribute msg) -> List (Element msg) -> Element msg
column properties children =
    Internal.parent
        (Internal.yogaProperty "flexDirection" (Json.string "column")
            :: properties
        )
        children


{-| -}
row : List (Attribute msg) -> List (Element msg) -> Element msg
row properties children =
    Internal.parent
        (Internal.yogaProperty "flexDirection" (Json.string "row")
            :: properties
        )
        children


{-| -}
map : (a -> msg) -> Element a -> Element msg
map =
    Internal.map


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
    Internal.program
