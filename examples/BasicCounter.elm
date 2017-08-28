module Main exposing (..)

import Element
    exposing
        ( Element
        , Attribute
        , column
        , row
        , button
        , label
        , map
        , beginnerProgram
        )
import Element.Attributes
    exposing
        ( text
        , textColor
        , fontSize
        , flexGrow
        , justifyContent
        , alignItems
        , marginHorizontal
        , marginBottom
        )
import Element.Events exposing (onTouchUpInside)
import Color exposing (Color)


main : Program Never Model Msg
main =
    beginnerProgram
        { model = 0
        , view = view
        , update = update
        }



-- MODEL


type alias Model =
    Int



-- UPDATE


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1



-- VIEW


view : Model -> Element Msg
view model =
    column [ flexGrow 1, justifyContent "center", alignItems "center" ]
        [ label [ text <| toString model, fontSize 50, marginBottom 25 ]
        , row []
            [ viewButton "Decrement" Decrement Color.red
            , viewButton "Increment" Increment Color.green
            ]
        ]


viewButton : String -> msg -> Color -> Element msg
viewButton label msg color =
    button
        [ text label
        , textColor color
        , fontSize 25
        , onTouchUpInside msg
        , marginHorizontal 20
        ]
