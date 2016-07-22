
port module Scrap exposing (..)

import Html exposing (..)

-- TODO: use IDs from mongo
-- TODO: use HtmlToScrap to make a function ((Html msg) -> (Html msg))
type alias Scrap msg =
    { name : String
    , htmler : (List (Html msg)) -> (List (Html msg))
    -- TODO: dictionary of options (eg color) to option type
    }

emptyScrap : Scrap msg
emptyScrap =
    { name = ""
    , htmler = (\_ -> [div [] []])
    }
    
