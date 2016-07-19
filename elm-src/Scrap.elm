
port module Scrap exposing (..)

import Html exposing (..)

-- TODO: use IDs from mongo
-- TODO: use HtmlToScrap to make a function ((Html msg) -> (Html msg))
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
    
