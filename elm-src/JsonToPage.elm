
port module JsonToPage exposing (parseJson)

import Json.Decode as Json exposing (..)
import Json.Decode.Extra as JsonExtra exposing (..)

import Page exposing (..)
import Scrap exposing (..)
import Pagelet exposing (..)

-- TODO: transform the scrap name into html using taysar.com/scrap/:name
scrapper : String -> Scrap msg
scrapper name =
    emptyScrap

pageleterer : String -> (List (Pagelet msg)) -> (Pagelet msg)
pageleterer scrapName pagelets =
    pageleter { scrap = (scrapper scrapName) } pagelets
        
-- TODO
-- TODO: use recursive case statement?
-- BUG: recursive decodePagelets is causing error
-- BUG: problem is actually pretty simple in https://github.com/elm-lang/core/blob/master/src/Native/Json.js
decodePagelet : Json.Decoder (Pagelet msg)
decodePagelet =
    object2 pageleterer
        ("scrap" := Json.string)
        ("pagelets" := (JsonExtra.lazy (\_ -> decodePagelets)))
        -- ("options" := Json.dict)

decodePagelets : Json.Decoder (List (Pagelet msg))
decodePagelets =
    Json.list decodePagelet 
            
decodePage : Json.Decoder (Page msg)
decodePage =
    object3 Page
        ("name" := Json.string)
        ("route" := Json.string)
        ("pagelets" := decodePagelets)

-- TODO: create the page here
decodePages : Json.Decoder (List (Page msg))
decodePages =
    Json.list decodePage

parseJson : Json.Decoder (List (Page msg))
parseJson = decodePages
