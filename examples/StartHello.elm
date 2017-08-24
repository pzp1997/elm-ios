module Main exposing (..)

import Element exposing (Element, column, label, program)
import Element.Attributes as Attributes
import Task


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }



-- MODEL


type alias Model =
    String


init : ( Model, Cmd Msg )
init =
    ( "", send Start )



-- UPDATE


type Msg
    = Start


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Start ->
            ( "Hello", Cmd.none )


send : msg -> Cmd msg
send msg =
    Task.succeed msg
        |> Task.perform identity



-- VIEW


view : Model -> Element msg
view model =
    column
        [ Attributes.flexGrow 1
        , Attributes.justifyContent "center"
        , Attributes.alignItems "center"
        ]
        [ label [ Attributes.text model ]
        ]
