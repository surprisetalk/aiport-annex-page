
-- TODO: change Scrap to (Maybe List Html msg -> Html msg)
-- TODO: scrap should accept a htmls and place them in scraphole

module JsonToScrap exposing (parseJson)

import List exposing (..)
import Html exposing (..)
import Scrap exposing (..)
import String exposing (..)
import JsonToHtml exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json exposing (..)

import Dict exposing (..)
import Json.Decode.Extra as JsonExtra exposing (..)

type HimalayaAttribute = HimalayaString String | HimalayaDict (Dict String String)

attributer : String -> HimalayaAttribute -> (Attribute msg)
attributer key val 
  = case val of
        HimalayaString s ->
            attribute key s
        HimalayaDict d ->
            style (Dict.values (Dict.map (,) d))

attributeser : Dict String HimalayaAttribute -> (List (Attribute msg))
attributeser attributes 
  = Dict.values (Dict.map attributer attributes)

parseAttributes : Json.Decoder (List (Attribute msg))
parseAttributes 
  = Json.map attributeser 
    <| Json.dict 
    <| Json.oneOf 
        [ Json.map HimalayaString Json.string
        , Json.map HimalayaDict (Json.dict Json.string) 
        ] 
        
tagger : String -> String
tagger tag 
  = if (endsWith "/" tag)
        then (dropRight 1 tag)
        else tag
            
noder : String -> List (Attribute msg) -> (List (Html msg) -> List (Html msg)) -> List (Html msg) -> Html msg
noder tag attributes htmler htmls
  = node tag attributes <| htmler htmls
    
texter : String -> List (Html msg) -> Html msg
texter str htmls
  = text str

-- TODO: i have to put the incoming html var into the function that parseElements returns in order to create the actual html node
parseElement : Json.Decoder ((List (Html msg)) -> (Html msg))
parseElement 
  = Json.oneOf
        [ Json.object3 noder
            ("tagName" := (Json.map tagger Json.string))
            ("attributes" := parseAttributes)
            ("children" := (JsonExtra.lazy (\_ -> parseElements)))
        , Json.object3 noder
            ("tagName" := (Json.map tagger Json.string))
            (Json.succeed [])
            ("children" := (JsonExtra.lazy (\_ -> parseElements)))
        , Json.object1 texter
            ("content" := Json.string)
        , Json.succeed <| (\_ -> div [] [text "error"])
        ]

variableMapper : List (a -> b) -> a -> List b
variableMapper functions
  = (\x -> List.map (\f -> f x) functions)

parseElements : Json.Decoder ((List (Html msg)) -> (List (Html msg)))
parseElements 
  = Json.map variableMapper <| Json.list parseElement

parseHimalaya : Json.Decoder ((List (Html msg)) -> (List (Html msg)))
parseHimalaya 
  = parseElements

-----------------------------------------------------

scrapify : String -> ((List (Html msg)) -> (List (Html msg))) -> Scrap msg
scrapify name htmler
  = { name = name
    , htmler = htmler
    }

parseScrap : Json.Decoder (Scrap msg)
parseScrap
  = Json.object2 scrapify
      ("name" := Json.string)
      ("html" := parseHimalaya)

parseJson : Json.Decoder (Scrap msg)
parseJson 
  = parseScrap

