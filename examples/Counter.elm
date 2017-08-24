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
import Element.Lazy exposing (lazy)
import Color exposing (Color)


main : Program Never Model Msg
main =
    beginnerProgram
        { model = 0
        , view = lazy view
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
    mapIfOdd model <|
        column [ flexGrow 1, justifyContent "center", alignItems "center" ]
            [ label <| maybeCons (labelColor model) [ text <| toString model, fontSize 50, marginBottom 25 ]
            , row []
                [ map (always Decrement) <|
                    makeButton "Decrement" "foo" Color.red (model > -10)
                , lazy lazyButton model
                ]
            ]


lazyButton : Model -> Element Msg
lazyButton counter =
    makeButton "Increment" Increment Color.green (counter < 10)


makeButton : String -> msg -> Color -> Bool -> Element msg
makeButton label msg defaultColor isEnabled =
    button <|
        [ text label
        , fontSize 25
        , marginHorizontal 20
        ]
            ++ if isEnabled then
                [ textColor defaultColor
                , onTouchUpInside msg
                ]
               else
                [ textColor Color.darkGrey ]


labelColor : Model -> Maybe (Attribute msg)
labelColor model =
    if model >= 5 then
        Just <| textColor Color.green
    else if model <= -5 then
        Just <| textColor Color.red
    else
        Nothing


maybeCons : Maybe a -> List a -> List a
maybeCons maybe list =
    case maybe of
        Just x ->
            x :: list

        Nothing ->
            list


mapIfOdd : Model -> (Element msg -> Element msg)
mapIfOdd model =
    if model % 2 == 1 then
        map identity
    else
        identity
