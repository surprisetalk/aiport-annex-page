
-- TODO: copy this module to create JsonToScrap
-- TODO: change Scrap to (Maybe List Html msg -> Html msg)
-- TODO: scrap should accept a htmls and place them in scraphole

-- TODO: publish this as elm-himalaya

module JsonToHtml exposing (parseJson)

import Dict exposing (..)
import Html exposing (..)
import String exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json exposing (..)
import Json.Decode.Extra as JsonExtra exposing (..)

type HimalayaAttribute = HimalayaString String | HimalayaDict (Dict String String)

attributer : String -> HimalayaAttribute -> (Attribute msg)
attributer key val =
    case val of
        HimalayaString s ->
            attribute key s
        HimalayaDict d ->
            style (Dict.values (Dict.map (,) d))

attributeser : Dict String HimalayaAttribute -> (List (Attribute msg))
attributeser attributes =
    Dict.values (Dict.map attributer attributes)

parseAttributes : Json.Decoder (List (Attribute msg))
parseAttributes =
    Json.map attributeser (Json.dict (Json.oneOf [ Json.map HimalayaString Json.string, Json.map HimalayaDict (Json.dict Json.string) ] ) )
        
tagger : String -> String
tagger tag =
    if (endsWith "/" tag)
        then (dropRight 1 tag)
        else tag
        
-- TODO: ignore non elements
parseElement : Json.Decoder (Html msg)
parseElement =
    Json.oneOf
    [ Json.object3 node
        ("tagName" := (Json.map tagger Json.string))
        ("attributes" := parseAttributes)
        ("children" := (JsonExtra.lazy (\_ -> parseElements)))
    , Json.object1 text
        ("content" := Json.string)
    ]

parseElements : Json.Decoder (List (Html msg))
parseElements =
   Json.list parseElement 
       
parseJson : Json.Decoder (List (Html msg))
parseJson = parseElements

