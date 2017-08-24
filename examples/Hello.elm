module Main exposing (..)

import Element exposing (Element, column, label, program)
import Element.Attributes exposing (flexGrow, justifyContent, alignItems, backgroundColor, text, textColor)
import Color


main : Program Never Model msg
main =
    program
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }



-- MODEL


type alias Model =
    ()


init : ( Model, Cmd msg )
init =
    ( (), Cmd.none )



-- UPDATE


update : msg -> Model -> ( Model, Cmd msg )
update msg model =
    init



-- VIEW


view : Model -> Element msg
view model =
    column
        [ flexGrow 1
        , justifyContent "center"
        , alignItems "center"
        , backgroundColor Color.yellow
        ]
        [ label
            [ text "Hello from Elm!"
            , textColor Color.red
            ]
        ]
