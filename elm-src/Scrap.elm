
port module Scrap exposing (..)

import Html exposing (..)

-- TODO: scrap.html really contains a route to the scrap, which accepts html/arguments and returns html
-- TODO: pass it a "blank" scrap for it to render in the empty spot
-- TODO: holes may not be visible in the viewer, so users should add subscraps in the scrap detail area
-- TODO: OR OR OR we can pass the actual scrap functions to the elm code on the server before sending
type alias Scrap msg =
    { name : String
    , html : Html msg
    -- TODO: dictionary of options (eg color) to option type
    }

emptyScrap : Scrap msg
emptyScrap =
    { name = ""
    , html = div [] []
    }
    
testScraps : List (Scrap msg)
testScraps =
    [ { name = "header", html = header [] [ h1 [] [ text "TAYSAR" ] ] }
    , { name = "body", html = article [] [ section [] [ p [] [ text "lorem ipsum" ] ] ] }
    , { name = "footer", html = footer [] [] }
    ]
    
