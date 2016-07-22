
port module JsonToPage exposing (parseJson)

import JsonToScrap

import Json.Decode as Json exposing (..)
import Json.Decode.Extra as JsonExtra exposing (..)

import Html exposing (..)

import Dict exposing (..)
import Page exposing (..)
import Scrap exposing (..)
import Pagelet exposing (..)

pageleterer : String -> (Scrap msg) -> List (Pagelet msg) -> (Pagelet msg)
pageleterer id scrap pagelets =
    pageleter { id = Just id, options = Dict.empty, scrap = scrap } pagelets
        
decodePagelet : Json.Decoder (Pagelet msg)
decodePagelet =
    object3 pageleterer
        ("_id" := Json.string)
        ("scrap" := JsonToScrap.parseJson)
        ("pagelets" := JsonExtra.lazy (\_ -> decodePagelets))
        -- ("options" := Json.succeed Dict.empty)

decodePagelets : Json.Decoder (List (Pagelet msg))
decodePagelets =
    Json.list decodePagelet 

decodePage : Json.Decoder (Page msg)
decodePage =
    object3 Page
        ("name" := Json.string)
        ("route" := Json.string)
        ("pagelets" := decodePagelets)

parseJson : Json.Decoder (Page msg)
parseJson = decodePage
