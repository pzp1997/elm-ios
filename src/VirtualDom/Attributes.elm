module VirtualDom.Attributes
    exposing
        ( map
        , text
        , textColor
        , textAlignment
        , font
        , fontSize
        , numberOfLines
        , lineBreakMode
        , shadowColor
        , shadowOffset
        , backgroundColor
        , justifyContent
        , flexWrap
        , alignItems
        , alignSelf
        , alignContent
        , flexGrow
        , flexShrink
        , flexBasis
        , position
        , left
        , top
        , right
        , bottom
        , start
        , end
        , minWidth
        , minHeight
        , maxWidth
        , maxHeight
        , width
        , height
        , margin
        , marginLeft
        , marginTop
        , marginRight
        , marginBottom
        , marginStart
        , marginEnd
        , marginVertical
        , marginHorizontal
        , padding
        , paddingLeft
        , paddingTop
        , paddingRight
        , paddingBottom
        , paddingStart
        , paddingEnd
        , paddingVertical
        , paddingHorizontal
        , borderWidth
        , borderLeftWidth
        , borderTopWidth
        , borderRightWidth
        , borderBottomWidth
        , borderStartWidth
        , borderEndWidth
        , aspectRatio
        , direction
        )

{-| #Attributes
@docs map, text, textColor, textAlignment, font, fontSize, numberOfLines, lineBreakMode, shadowColor, shadowOffset, backgroundColor, justifyContent, flexWrap, alignItems, alignSelf, alignContent, flexGrow, flexShrink, flexBasis, position, left, top, right, bottom, start, end, minWidth, minHeight, maxWidth, maxHeight, width, height, margin, marginLeft, marginTop, marginRight, marginBottom, marginStart, marginEnd, marginVertical, marginHorizontal, padding, paddingLeft, paddingTop, paddingRight, paddingBottom, paddingStart, paddingEnd, paddingVertical, paddingHorizontal, borderWidth, borderLeftWidth, borderTopWidth, borderRightWidth, borderBottomWidth, borderStartWidth, borderEndWidth, aspectRatio, direction
-}

import Color exposing (Color)
import Json.Encode as Json
import VirtualDom
import VirtualDom.Element exposing (Attribute)


{- Property Helpers -}


stringProperty : String -> String -> Attribute msg
stringProperty name string =
    VirtualDom.property name (Json.string string)


intProperty : String -> Int -> Attribute msg
intProperty name int =
    VirtualDom.property name (Json.int int)


floatProperty : String -> Float -> Attribute msg
floatProperty name float =
    VirtualDom.property name (Json.float float)


colorProperty : String -> Color -> Attribute msg
colorProperty name color =
    let
        rgb =
            Color.toRgb color
    in
        VirtualDom.property name
            (Json.list
                [ Json.int rgb.red
                , Json.int rgb.green
                , Json.int rgb.blue
                , Json.float rgb.alpha
                ]
            )



{- Yoga Property Helpers -}


stringYogaProperty : String -> String -> Attribute msg
stringYogaProperty name string =
    VirtualDom.yogaProperty name (Json.string string)


intYogaProperty : String -> Int -> Attribute msg
intYogaProperty name int =
    VirtualDom.yogaProperty name (Json.int int)


floatYogaProperty : String -> Float -> Attribute msg
floatYogaProperty name float =
    VirtualDom.yogaProperty name (Json.float float)



{- Map -}


{-| -}
map : (a -> msg) -> Attribute a -> Attribute msg
map =
    VirtualDom.mapProperty



{- Label -}


{-| -}
text : String -> Attribute msg
text value =
    stringProperty "text" value


{-| -}
textColor : Color -> Attribute msg
textColor value =
    colorProperty "textColor" value


{-| -}
textAlignment : String -> Attribute msg
textAlignment value =
    stringProperty "textAlignment" value


{-| -}
font : String -> Attribute msg
font value =
    stringProperty "font" value


{-| -}
fontSize : Float -> Attribute msg
fontSize value =
    floatProperty "fontSize" value


{-| -}
numberOfLines : Int -> Attribute msg
numberOfLines value =
    intProperty "numberOfLines" value


{-| -}
lineBreakMode : String -> Attribute msg
lineBreakMode value =
    stringProperty "lineBreakMode" value


{-| -}
shadowColor : Color -> Attribute msg
shadowColor value =
    colorProperty "shadowColor" value


{-| -}
shadowOffset : Float -> Float -> Attribute msg
shadowOffset xOffset yOffset =
    VirtualDom.property "shadowOffset"
        (Json.list
            [ Json.float xOffset
            , Json.float yOffset
            ]
        )



{- View -}


{-| -}
backgroundColor : Color -> Attribute msg
backgroundColor value =
    colorProperty "backgroundColor" value



{- Yoga -}
-- Flexbox properties


{-| -}
justifyContent : String -> Attribute msg
justifyContent value =
    stringYogaProperty "justifyContent" value


{-| -}
flexWrap : String -> Attribute msg
flexWrap value =
    stringYogaProperty "flexWrap" value


{-| -}
alignItems : String -> Attribute msg
alignItems value =
    stringYogaProperty "alignItems" value


{-| -}
alignSelf : String -> Attribute msg
alignSelf value =
    stringYogaProperty "alignSelf" value


{-| -}
alignContent : String -> Attribute msg
alignContent value =
    stringYogaProperty "alignContent" value


{-| -}
flexGrow : Float -> Attribute msg
flexGrow value =
    floatYogaProperty "flexGrow" value


{-| -}
flexShrink : Float -> Attribute msg
flexShrink value =
    floatYogaProperty "flexShrink" value


{-| -}
flexBasis : Float -> Attribute msg
flexBasis value =
    floatYogaProperty "flexBasis" value



-- Absolute positioning


{-| -}
position : String -> Attribute msg
position value =
    stringYogaProperty "position" value


{-| -}
left : Float -> Attribute msg
left value =
    floatYogaProperty "left" value


{-| -}
top : Float -> Attribute msg
top value =
    floatYogaProperty "top" value


{-| -}
right : Float -> Attribute msg
right value =
    floatYogaProperty "right" value


{-| -}
bottom : Float -> Attribute msg
bottom value =
    floatYogaProperty "bottom" value


{-| -}
start : Float -> Attribute msg
start value =
    floatYogaProperty "start" value


{-| -}
end : Float -> Attribute msg
end value =
    floatYogaProperty "end" value



-- Width and height


{-| -}
minWidth : Float -> Attribute msg
minWidth value =
    floatYogaProperty "minWidth" value


{-| -}
minHeight : Float -> Attribute msg
minHeight value =
    floatYogaProperty "minHeight" value


{-| -}
maxWidth : Float -> Attribute msg
maxWidth value =
    floatYogaProperty "maxWidth" value


{-| -}
maxHeight : Float -> Attribute msg
maxHeight value =
    floatYogaProperty "maxHeight" value


{-| -}
width : Float -> Attribute msg
width value =
    floatYogaProperty "width" value


{-| -}
height : Float -> Attribute msg
height value =
    floatYogaProperty "height" value



-- Margin


{-| -}
margin : Float -> Attribute msg
margin value =
    floatYogaProperty "margin" value


{-| -}
marginLeft : Float -> Attribute msg
marginLeft value =
    floatYogaProperty "marginLeft" value


{-| -}
marginTop : Float -> Attribute msg
marginTop value =
    floatYogaProperty "marginTop" value


{-| -}
marginRight : Float -> Attribute msg
marginRight value =
    floatYogaProperty "marginRight" value


{-| -}
marginBottom : Float -> Attribute msg
marginBottom value =
    floatYogaProperty "marginBottom" value


{-| -}
marginStart : Float -> Attribute msg
marginStart value =
    floatYogaProperty "marginStart" value


{-| -}
marginEnd : Float -> Attribute msg
marginEnd value =
    floatYogaProperty "marginEnd" value


{-| -}
marginVertical : Float -> Attribute msg
marginVertical value =
    floatYogaProperty "marginVertical" value


{-| -}
marginHorizontal : Float -> Attribute msg
marginHorizontal value =
    floatYogaProperty "marginHorizontal" value



-- Padding


{-| -}
padding : Float -> Attribute msg
padding value =
    floatYogaProperty "padding" value


{-| -}
paddingLeft : Float -> Attribute msg
paddingLeft value =
    floatYogaProperty "paddingLeft" value


{-| -}
paddingTop : Float -> Attribute msg
paddingTop value =
    floatYogaProperty "paddingTop" value


{-| -}
paddingRight : Float -> Attribute msg
paddingRight value =
    floatYogaProperty "paddingRight" value


{-| -}
paddingBottom : Float -> Attribute msg
paddingBottom value =
    floatYogaProperty "paddingBottom" value


{-| -}
paddingStart : Float -> Attribute msg
paddingStart value =
    floatYogaProperty "paddingStart" value


{-| -}
paddingEnd : Float -> Attribute msg
paddingEnd value =
    floatYogaProperty "paddingEnd" value


{-| -}
paddingVertical : Float -> Attribute msg
paddingVertical value =
    floatYogaProperty "paddingVertical" value


{-| -}
paddingHorizontal : Float -> Attribute msg
paddingHorizontal value =
    floatYogaProperty "paddingHorizontal" value



-- Border


{-| -}
borderWidth : Float -> Attribute msg
borderWidth value =
    floatYogaProperty "borderWidth" value


{-| -}
borderLeftWidth : Float -> Attribute msg
borderLeftWidth value =
    floatYogaProperty "borderLeftWidth" value


{-| -}
borderTopWidth : Float -> Attribute msg
borderTopWidth value =
    floatYogaProperty "borderTopWidth" value


{-| -}
borderRightWidth : Float -> Attribute msg
borderRightWidth value =
    floatYogaProperty "borderRightWidth" value


{-| -}
borderBottomWidth : Float -> Attribute msg
borderBottomWidth value =
    floatYogaProperty "borderBottomWidth" value


{-| -}
borderStartWidth : Float -> Attribute msg
borderStartWidth value =
    floatYogaProperty "borderStartWidth" value


{-| -}
borderEndWidth : Float -> Attribute msg
borderEndWidth value =
    floatYogaProperty "borderEndWidth" value



-- Other


{-| -}
aspectRatio : Float -> Attribute msg
aspectRatio value =
    floatYogaProperty "aspectRatio" value


{-| -}
direction : String -> Attribute msg
direction value =
    stringYogaProperty "direction" value
