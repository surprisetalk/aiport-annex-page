
-- TODO: we can use type Dict!!!!

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Random

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- HELPERS

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

type alias Model =
    { pages : List Page
    , scraps : List Scrap
    , page : Page
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
    
type alias Scrap =
    { name : String
    , html : Html Msg
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
    , scraps = testScraps
    }
  , Cmd.none
  )


-- UPDATE

type Msg
  = ViewPage Page

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ViewPage page ->
      ({ model | page = page }, Cmd.none)


-- SUBSCRIPTIONS

-- TODO: look at elm-markdown for how to parse html into the virtual-dom
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- VIEW

view : Model -> Html Msg
view model =
  div [] 
    [ pageNav model.pages
    , pageDetails model.page
    , pageBuild model.page.pagelets
    , scrapsNav model.scraps 
    ]
      
pageNav : List Page -> Html Msg
pageNav pages =
  aside []
    [ ul []
        (List.map pageLink pages)
    ]
      
pageLink : Page -> Html Msg
pageLink page =
    li [] [ a [onClick (ViewPage page), href "#"] [ text page.name ] ]

pageDetails : Page -> Html Msg
pageDetails page =
  article [] 
    [ ul []
        [ li [] [ text page.name ]
        , li [] [ text page.route ]
        ]
    ]
      
render : Pagelet -> Html Msg
render pagelet =
  (.html (.scrap (pick pagelet)))

pageletBuild : Pagelet -> Html Msg
pageletBuild pagelet =
  section [] [ render pagelet ]

pageBuild : List Pagelet -> Html Msg
pageBuild pagelets =
  article [] (List.map pageletBuild pagelets)
      
scrapsNav : List Scrap -> Html Msg
scrapsNav scraps =
  aside []
    [ ul []
        (List.map scrapLink scraps)
    ]
            
scrapLink : Scrap -> Html Msg
scrapLink scrap =
    li [] [ a [] [ text scrap.name ] ]


