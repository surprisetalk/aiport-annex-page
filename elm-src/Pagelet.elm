
port module Pagelet exposing (..)

import Tree exposing (..)
import Scrap exposing (..)

(?) : Maybe a -> a -> a
(?) maybe default =
  Maybe.withDefault default maybe


type alias PageletNode msg =
    { scrap : Scrap msg
    -- TODO: dictionary of options to values for the scrap
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
        { scrap = emptyScrap
        -- , stuff = []
        } 

testPagelet : Pagelet msg
testPagelet 
    = sprout 
        { scrap = (List.head testScraps) ? emptyScrap
        -- , stuff = []
        } 

