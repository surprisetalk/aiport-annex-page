
-- TODO: we can use type Dict!!!!
-- TODO: split this up into different files under src
-- TODO: look at elm-markdown for how to parse html into the virtual-dom

port module Main exposing (..)
    
import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import JsonToHtml
import JsonToPage 
import String
import Task
import Http
            
import Pagelet exposing (..)
import Scrap exposing (..)
import Page exposing (..)
import Tree exposing (..)

main : Program Never
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- HELPERS

(=>) : a -> b -> ( a, b )
(=>) = (,)

(?) : Maybe a -> a -> a
(?) maybe default =
  Maybe.withDefault default maybe


-- MODEL

-- TODO: remove page and pagelet in favor of .active
-- TODO: page and pagelet are copies, which means we have to sync in a few places...
-- TODO: OR pagelets will have IDs, which means we can subscribe to the db :3
type alias Model =
    { pages : List (Page Msg)
    , scraps : List (Scrap Msg)
    , page : Page Msg
    , pagelet : Pagelet Msg
    , workspace : Html Msg
    }
    
init : (Model, Cmd Msg)
init =
  ( { pages = testPages
    , page = (List.head testPages) ? emptyPage 
    , pagelet = emptyPagelet
    , scraps = testScraps
    , workspace = div [ styleColumn 50 "white" ] []
    }
  , fetchPages
  )


-- UPDATE

type Msg
  = ViewPage (Page Msg)
  | SelectPagelet (Pagelet Msg)
  | SelectScrap (Scrap Msg)
  | FetchPageSucceed (List (Page Msg))
  | FetchScrapSucceed (List (Html Msg))
  | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ViewPage page ->
      ({ model | page = page }, Cmd.none)
    SelectPagelet pagelet ->
      ({ model | pagelet = pagelet }, Cmd.none)
    SelectScrap scrap ->
      ({ model | pagelet = setScrap model.pagelet scrap }, Cmd.none)
    -- KLUDGE: shouldn't be chaining the commands like this
    FetchPageSucceed pages ->
      ({ model | pages = pages }, Debug.log "FetchPageSucceed" fetchScraps)
    FetchScrapSucceed htmls ->
      ({ model | workspace = div [ styleColumn 50 "white" ] htmls }, Debug.log "FetchScrapSucceed" Cmd.none)
    FetchFail error ->
      case error of
          Http.Timeout ->
              (model, Debug.log "timeout" Cmd.none)
          Http.NetworkError ->
              (model, Debug.log "network error" Cmd.none)
          Http.UnexpectedPayload stuff ->
              (model, Debug.log stuff Cmd.none)
          Http.BadResponse code stuff ->
              (model, Debug.log (stuff ++ toString code) Cmd.none)
              


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- VIEW

styleColumn : a -> String -> Attribute b
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
    -- , pageBuild model.pagelet model.page.pagelets
    , model.workspace
    , pageletDetails model.pagelet model.scraps 
    ]
      
pageNav : List (Page Msg) -> Html Msg
pageNav pages =
  aside [ styleColumn 15 "#E8E8E8" ]
    [ ul []
        (List.map pageLink pages)
    ]
      
pageLink : Page Msg -> Html Msg
pageLink page =
    li [] [ a [onClick (ViewPage page), href "#"] [ text page.name ] ]

pageDetails : Page Msg -> Html Msg
pageDetails page =
  article [ styleColumn 10 "#EEE" ] 
    [ ul []
        [ li [] [ text page.name ]
        , li [] [ text page.route ]
        ]
    ]
      
render : Pagelet Msg -> Html Msg
render pagelet =
  (.html (.scrap (pick pagelet)))

pageletBuild : Pagelet Msg -> Pagelet Msg -> Html Msg
pageletBuild the_pagelet a_pagelet =
  section [ onClick (SelectPagelet a_pagelet), style [ "background-color" => ( if a_pagelet == the_pagelet then "#EEE" else "white" ) ] ] [ render a_pagelet ]

pageBuild : Pagelet Msg -> List (Pagelet Msg) -> Html Msg
pageBuild the_pagelet pagelets =
  article [ styleColumn 50 "white" ] (List.map (pageletBuild the_pagelet) pagelets)
      
pageletDetails : Pagelet Msg -> List (Scrap Msg) -> Html Msg
pageletDetails pagelet scraps =
  aside [ styleColumn 25 "#EEE" ]
    [ h2 [] [ text (.name (.scrap (pick pagelet))) ]
    , if (String.isEmpty (.name (.scrap (pick pagelet)))) then (ul [] []) else scrapsNav scraps
    ]
      
scrapsNav : List (Scrap Msg) -> Html Msg
scrapsNav scraps =
    ul [] (List.map scrapLink scraps)      

scrapLink : Scrap Msg -> Html Msg
scrapLink scrap =
    li [] [ a [ onClick (SelectScrap scrap), href "#" ] [ text scrap.name ] ]


-- HTTP

fetchPages : Cmd Msg
fetchPages =
    let
        url = "http://taysar.com:9097/pile/page"
    in
        Task.perform FetchFail FetchPageSucceed 
        <| Http.get JsonToPage.parseJson url
            
fetchScraps : Cmd Msg
fetchScraps = 
    let
        url = "http://taysar.com:9097/scrap/json/taysar"
        body = Http.empty
    in
        Task.perform FetchFail FetchScrapSucceed 
        <| Http.post JsonToHtml.parseJson url body
        
