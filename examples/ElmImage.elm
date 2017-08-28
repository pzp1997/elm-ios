module Main exposing (..)

import Element exposing (Element, column, image, label, beginnerProgram)
import Element.Attributes
    exposing
        ( src
        , text
        , fontSize
        , flexGrow
        , justifyContent
        , alignItems
        , width
        , height
        , margin
        )


main : Program Never {} msg
main =
    beginnerProgram
        { model = {}
        , view = view
        , update = \_ _ -> {}
        }


view : {} -> Element msg
view _ =
    column [ flexGrow 1, justifyContent "center", alignItems "center" ]
        [ image [ src "elm_logo_small.png", width 200, height 200, margin 40 ]
        , label [ text "Elm on iOS", fontSize 30 ]
        ]
