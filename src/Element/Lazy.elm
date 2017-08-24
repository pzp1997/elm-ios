module Element.Lazy exposing (lazy, lazy2, lazy3)

{-| #Lazy
@docs lazy, lazy2, lazy3
-}

import Element exposing (Element)
import Element.Internal as Internal


{-| -}
lazy : (a -> Element msg) -> a -> Element msg
lazy =
    Internal.lazy


{-| -}
lazy2 : (a -> b -> Element msg) -> a -> b -> Element msg
lazy2 =
    Internal.lazy2


{-| -}
lazy3 : (a -> b -> c -> Element msg) -> a -> b -> c -> Element msg
lazy3 =
    Internal.lazy3
