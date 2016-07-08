
-- TODO: we can use type Dict!!!!
-- TODO: split this up into different files under src
-- TODO: look at elm-markdown for how to parse html into the virtual-dom

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import String
import Random

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- HELPERS

(=>) = (,)

(?) : Maybe a -> a -> a
(?) maybe default =
  Maybe.withDefault default maybe


-- TREE

type Tree a = Node a (List (Tree a))
      
sprout : a -> Tree a
sprout v = 
    Node v []

pick : Tree a -> a
pick tree = 
    let 
        (Node v _) = tree
    in 
        v
            
-- MODEL

-- TODO: remove page and pagelet in favor of .active
-- TODO: page and pagelet are copies, which means we have to sync in a few places...
type alias Model =
    { pages : List Page
    , scraps : List Scrap
    , page : Page
    , pagelet : Pagelet
    }
    
type alias Page =
    { name : String
    , route : String
    , pagelets : List Pagelet
    }
    
type alias PageletNode =
    { scrap : Scrap
    -- , stuff : List Pagelet
    }
    
type alias Pagelet = Tree PageletNode
    
setScrap : Pagelet -> Scrap -> Pagelet
setScrap pagelet scrap =
    let
        (Node v n) = pagelet
    in
        Node { v | scrap = scrap } n
    
-- TODO: scrap.html really contains a route to the scrap, which accepts html/arguments and returns html
-- TODO: pass it a "blank" scrap for it to render in the empty spot
-- TODO: holes may not be visible in the viewer, so users should add subscraps in the scrap detail area
type alias Scrap =
    { name : String
    , html : Html Msg
    -- TODO: dictionary of options, like color, etc
    }

emptyScrap : Scrap
emptyScrap =
    { name = ""
    , html = div [] []
    }
    
testScraps : List Scrap
testScraps =
    [ { name = "header", html = header [] [ h1 [] [ text "TAYSAR" ] ] }
    , { name = "body", html = article [] [ section [] [ p [] [ text "lorem ipsum" ] ] ] }
    , { name = "footer", html = footer [] [] }
    ]
    
emptyPage : Page
emptyPage =
    { name = ""
    , route = ""
    , pagelets = []
    }
    
emptyPagelet : Pagelet
emptyPagelet 
    = sprout 
        { scrap = emptyScrap
        -- , stuff = []
        } 

testPagelet : Pagelet
testPagelet 
    = sprout 
        { scrap = (List.head testScraps) ? emptyScrap
        -- , stuff = []
        } 
    
testPages : List Page
testPages =
    [ { name = "home", route = "/", pagelets = [ testPagelet ] }
    , { name = "about", route = "/about", pagelets = [] }
    , { name = "contact", route = "/contact", pagelets = [] }
    ]

init : (Model, Cmd Msg)
init =
  ( { pages = testPages
    , page = (List.head testPages) ? emptyPage 
    , pagelet = emptyPagelet
    , scraps = testScraps
    }
  , Cmd.none
  )


-- UPDATE

type Msg
  = ViewPage Page
  | SelectPagelet Pagelet
  | SelectScrap Scrap

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ViewPage page ->
      ({ model | page = page }, Cmd.none)
    SelectPagelet pagelet ->
      ({ model | pagelet = pagelet }, Cmd.none)
    SelectScrap scrap ->
      ({ model | pagelet = setScrap model.pagelet scrap }, Cmd.none)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- VIEW

styleColumn width color = 
  style 
    [ "float" => "left"
    , "margin" => "0"
    , "overflow" => "auto"
    , "width" => ( (toString width) ++ "%" )
    , "height" => "100%"
    , "background-color" => color
    ]

view : Model -> Html Msg
view model =
  div [ style [ "height" => "100%" ] ] 
    [ pageNav model.pages
    , pageDetails model.page
    , pageBuild model.pagelet model.page.pagelets
    , pageletDetails model.pagelet model.scraps 
    ]
      
pageNav : List Page -> Html Msg
pageNav pages =
  aside [ styleColumn 15 "#E8E8E8" ]
    [ ul []
        (List.map pageLink pages)
    ]
      
pageLink : Page -> Html Msg
pageLink page =
    li [] [ a [onClick (ViewPage page), href "#"] [ text page.name ] ]

pageDetails : Page -> Html Msg
pageDetails page =
  article [ styleColumn 10 "#EEE" ] 
    [ ul []
        [ li [] [ text page.name ]
        , li [] [ text page.route ]
        ]
    ]
      
render : Pagelet -> Html Msg
render pagelet =
  (.html (.scrap (pick pagelet)))

pageletBuild : Pagelet -> Pagelet -> Html Msg
pageletBuild the_pagelet a_pagelet =
  section [ onClick (SelectPagelet a_pagelet), style [ "background-color" => ( if a_pagelet == the_pagelet then "#EEE" else "white" ) ] ] [ render a_pagelet ]

pageBuild : Pagelet -> List Pagelet -> Html Msg
pageBuild the_pagelet pagelets =
  article [ styleColumn 50 "white" ] (List.map (pageletBuild the_pagelet) pagelets)
      
pageletDetails : Pagelet -> List Scrap -> Html Msg
pageletDetails pagelet scraps =
  aside [ styleColumn 25 "#EEE" ]
    [ h2 [] [ text (.name (.scrap (pick pagelet))) ]
    , if (String.isEmpty (.name (.scrap (pick pagelet)))) then (ul [] []) else scrapsNav scraps
    ]
      
scrapsNav : List Scrap -> Html Msg
scrapsNav scraps =
    ul [] (List.map scrapLink scraps)      

scrapLink : Scrap -> Html Msg
scrapLink scrap =
    li [] [ a [ onClick (SelectScrap scrap), href "#" ] [ text scrap.name ] ]


