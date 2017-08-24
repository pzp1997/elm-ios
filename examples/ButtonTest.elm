module Main exposing (..)

import Element
    exposing
        ( Element
        , column
        , label
        , button
        , program
        )
import Element.Attributes
    exposing
        ( flexGrow
        , justifyContent
        , alignItems
        , text
        )
import Element.Events exposing (onTouchUpInside)


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    Int


init : ( Model, Cmd Msg )
init =
    ( 0, Cmd.none )



-- UPDATE


type Msg
    = ButtonClick


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ButtonClick ->
            ( model + 1, Cmd.none )



-- VIEW


view : Model -> Element Msg
view model =
    column
        [ flexGrow 1
        , justifyContent "center"
        , alignItems "center"
        ]
        [ label [ text <| toString model ]
        , button [ text "Press me!", onTouchUpInside ButtonClick ]
        ]
