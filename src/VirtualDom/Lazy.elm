module VirtualDom.Lazy exposing (lazy, lazy2, lazy3)

{-| #Lazy
@docs lazy, lazy2, lazy3
-}

import VirtualDom.Element exposing (Element)
import VirtualDom


{-| -}
lazy : (a -> Element msg) -> a -> Element msg
lazy =
    VirtualDom.lazy


{-| -}
lazy2 : (a -> b -> Element msg) -> a -> b -> Element msg
lazy2 =
    VirtualDom.lazy2


{-| -}
lazy3 : (a -> b -> c -> Element msg) -> a -> b -> c -> Element msg
lazy3 =
    VirtualDom.lazy3
