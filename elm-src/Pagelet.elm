
port module Pagelet exposing (..)

import Dict exposing (..)
import Tree exposing (..)
import Scrap exposing (..)

(?) : Maybe a -> a -> a
(?) maybe default =
  Maybe.withDefault default maybe


type alias PageletNode msg =
    { id : Maybe String
    , scrap : Scrap msg
    , options : Dict String String
    }
    
type alias Pagelet msg = Tree (PageletNode msg)
    
-- TODO: better annotation
pageleter : a -> List (Tree a) -> Tree a
pageleter a b =
    Node a b
    
setScrap : Pagelet msg -> Scrap msg -> Pagelet msg
setScrap pagelet scrap =
    let
        (Node v n) = pagelet
    in
        Node { v | scrap = scrap } n
    

emptyPagelet : Pagelet msg
emptyPagelet 
    = sprout 
        { id = Nothing
        , scrap = emptyScrap
        , options = Dict.empty
        } 

testPagelet : Pagelet msg
testPagelet 
    = sprout 
        { id = Nothing
        , scrap = emptyScrap
        , options = Dict.empty
        } 

