
port module Main exposing (..)
    
import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json
import JsonToScrap
import JsonToPage
import JsonToHtml
import WebSocket
import String
import Result
import Task
import Http
            
-- TODO: put the Json encoders inside modules, eg Pagelet.JsonDecode
import Pagelet exposing (..)
import Scrap exposing (..)
import Page exposing (..)
import Tree exposing (..)

main : Program Never
main 
  = Html.program
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

-- TODO: get it working without drag/drop first

-- TODO: give pagelets own pile
-- TODO: pages and pagelets have IDs in mongo, so let's save them by id?

type alias Model 
  = { pages : List (Page Msg)
    , scraps : List (Scrap Msg)
    , workspace : Workspace
    }
   
type alias Workspace
  = { hoverscrap : Maybe (Scrap Msg)
    , overpagelets : List (Scrap Msg)
    , page : Maybe (Page Msg)
    , pagelet : Maybe (Pagelet Msg)
    }
    
init : (Model, Cmd Msg)
init 
  = ( { pages = []
      , scraps = []
      , workspace 
      = { hoverscrap = Nothing
        , overpagelets = []
        , page = Nothing
        , pagelet = Nothing
        }
      } 
    -- TODO: fetch pages and scraps
    , Cmd.none
    )

localhost : String
localhost 
  = "ws://taysar.com:9097/"
    

-- UPDATE

-- TODO: Scrap needs to change to function

type Msg
  = LoadPages (List (Page Msg))
  | LoadScraps (List (Scrap Msg))
  | SelectPage (Page Msg)
  | SelectPagelet (Pagelet Msg)
  | UpdatePage (Page Msg)
  | UpdatePageName String
  | UpdatePageRoute String
  -- | SavePage (Page Msg)
  -- | SavePagelet (Pagelet Msg)
  -- | DragScrap (Scrap Msg) 
  -- | DropScrap (Scrap Msg)
  -- | MouseEnterPagelet (Pagelet Msg) 
  -- | MouseLeavePagelet (Pagelet Msg)
  -- | HttpSucceedSavePage (Html Msg)
  -- | HttpSucceedSavePagelet (Html Msg)
  -- | HttpSucceedFetchPages (List (Page Msg))
  -- | HttpSucceedFetchScraps (List (Html Msg))
  -- | HttpFail Http.Error
  -- | TestMessage String


-- TODO: comment all cases and slowly introduce them back to find errors

update : Msg -> Model -> (Model, Cmd Msg)
update msg model 
  = case msg of
      LoadPages pages ->
          ({ model | pages = pages }, Cmd.none)
      LoadScraps scraps ->
          ({ model | scraps = scraps }, Cmd.none)
      SelectPage page ->
          let 
              workspace = model.workspace
          in 
              ({ model | workspace = { workspace | page = Just page } }, Cmd.none)
      SelectPagelet pagelet ->
          let 
              workspace = model.workspace
          in 
              ({ model | workspace = { workspace | pagelet = Just pagelet } }, Cmd.none)
      -- TODO: make custom event handler onSubmit (Json.succeed (HtmlToPage children)) and put it on workspace area
      UpdatePage page ->
          let 
              workspace = model.workspace
              page = model.workspace.page
          in 
              ({ model | workspace = { workspace | page = page } }, Cmd.none)
      UpdatePageName name ->
          let 
              workspace = model.workspace
          in 
              case model.workspace.page of
                  Nothing ->
                      (model, Cmd.none)
                  Just page ->
                      ({ model | workspace = { workspace | page = Just { page | name = name } } }, Cmd.none)
      UpdatePageRoute route ->
          let 
              workspace = model.workspace
          in 
              case model.workspace.page of
                  Nothing ->
                      (model, Cmd.none)
                  Just page ->
                      ({ model | workspace = { workspace | page = Just { page | route = route } } }, Cmd.none)
      -- SavePage page ->
      --     let 
      --         saver
      --         = Task.perform HttpFail HttpSucceedSavePage 
      --           -- TODO: { _id: null, pagelet_id: null, name: null, route: null }
      --           <| Http.post (Json.succeed Nothing) (localhost ++ "pile/page") Http.empty
      --     in
      --         (model, saver)
      -- SavePagelet pagelet ->
      --     let 
      --         saver
      --         = Task.perform HttpFail HttpSucceedSavePagelet
      --           -- TODO: { _id: null, pagelet_ids: null, scrap_id: null, options: {} }
      --           <| Http.post (Json.succeed Nothing) (localhost ++ "pile/pagelet") Http.empty
      --     in
      --         (model, saver)
      -- DragScrap scrap ->
      --     let 
      --         workspace = model.workspace
      --     in 
      --         ({ model | workspace = { workspace | hoverscrap = scrap } }, Cmd.none)
      -- DropScrap scrap ->
      --     case model.workspace.overpagelets of 
      --         [] ->
      --             (model, Cmd.none)
      --         overpagelet::_ ->
      --             let 
      --                 workspace = model.workspace
      --             in 
      --                 ({ model | workspace = { workspace | hoverscrap = Nothing, pagelet = Pagelet.setScrap overpagelet scrap } }, Cmd.none)
      -- MouseEnterPagelet pagelet ->
      --     let 
      --         workspace = model.workspace
      --     in 
      --         case model.workspace.hoverscrap of
      --             Nothing ->
      --                 ({ model | workspace = { workspace | overpagelets = pagelet :: model.workspace.overpagelets } }, Cmd.none)
      --             Just hoverscrap ->
      --                 ({ model | workspace = { workspace | overpagelets = pagelet :: model.workspace.overpagelets, pagelet = pagelet } }, Cmd.none)
      -- MouseLeavePagelet pagelet ->
      --     let 
      --         workspace = model.workspace
      --     in 
      --         ({ model | workspace = { workspace | overpagelets = List.filter ((/=) pagelet) model.workspace.overpagelets } }, Cmd.none)
      -- -- KLUDGE: shouldn't be chaining the commands like this
      -- HttpSucceedSavePage page ->
      --     let 
      --         workspace = model.workspace
      --     in 
      --         ({ model | workspace = { workspace | page = page } }, Debug.log "FetchPageSucceed" Cmd.none)
      -- HttpSucceedSavePagelet pagelet ->
      --     let 
      --         workspace = model.workspace
      --     in 
      --         ({ model | workspace = { workspace | pagelet = pagelet } }, Debug.log "FetchPageSucceed" Cmd.none)
      -- HttpSucceedFetchPages pages ->
      --     ({ model | pages = pages }, Debug.log "FetchPageSucceed" Cmd.none)
      -- HttpSucceedFetchScraps htmls ->
      --     ({ model | workspace = div [] htmls }, Debug.log "FetchScrapSucceed" Cmd.none)
      -- HttpFail error ->
      --     case error of
      --         Http.Timeout ->
      --             (model, Debug.log "timeout" Cmd.none)
      --         Http.NetworkError ->
      --             (model, Debug.log "network error" Cmd.none)
      --         Http.UnexpectedPayload stuff ->
      --             (model, Debug.log stuff Cmd.none)
      --         Http.BadResponse code stuff ->
      --             (model, Debug.log (stuff ++ toString code) Cmd.none)
      -- TestMessage message ->
      --     (model, Debug.log message Cmd.none)


-- SUBSCRIPTIONS

-- TODO: subscribe to pages
-- TODO: subscribe to scraps
-- TODO: subscribe to mouse down

subscriptions : Model -> Sub Msg
subscriptions model 
  = Sub.batch
    [ WebSocket.listen "ws://taysar.com:9097/pile/page" 
        <| LoadPages << Result.withDefault model.pages << Json.decodeString (Json.list JsonToPage.parseJson)
    , WebSocket.listen "ws://taysar.com:9097/pile/scrap" 
        <| LoadScraps << Result.withDefault model.scraps << Json.decodeString (Json.list JsonToScrap.parseJson)
    ]

-- VIEW

styleColumn : a -> String -> Attribute b
styleColumn width color 
  = style 
    [ "float" => "left"
    , "margin" => "0"
    , "overflow" => "auto"
    , "width" => ( (toString width) ++ "%" )
    , "height" => "100%"
    , "background-color" => color
    ]

-- TODO: all this crap
-- TODO: remember that scraps are supposed to be functions that generate html blah blah blah

view : Model -> Html Msg
view model 
  = div 
    [ style [ "height" => "100%" ] ] 
    [ pagesAside model.pages
    , workspaceGroup model.workspace
    , scrapsAside model.scraps 
    ]
    
pagesAside : List (Page Msg) -> Html Msg
pagesAside pages
  = aside [ styleColumn 10 "#E8E8E8" ] [ pagesNav pages ]
    
pagesNav : List (Page Msg) -> Html Msg
pagesNav pages
  = ul [] <| List.map pageLink pages
   
pageLink : Page Msg -> Html Msg
pageLink page
  = li [] [ a [ href "#", onClick <| SelectPage page ] [ text page.name ] ]
          
-- TODO: this logic doesn't really belong here...
workspaceGroup : Workspace -> Html Msg
workspaceGroup workspace
  = case workspace.page of
        Nothing ->
            div [ styleColumn 80 "white" ] []
        Just page ->
            div 
            [ styleColumn 80 "white" ] 
            [ pageDetails page
            , pageletDetails workspace.pagelet 
            , workspaceDetails page
            ]
    
pageDetails : Page Msg -> Html Msg
pageDetails page
  = div [ styleColumn 25 "#ECECEC" ]
    [ label [ style [ "display" => "block "] ] [ text "name", input [ value page.name ] [] ]
    , label [ style [ "display" => "block "] ] [ text "route", input [ value page.route ] [] ]
    ]
          
-- TODO: this logic doesn't really belong here...
-- TODO: move the pagelet details under the page details
-- TODO: options!
pageletDetails : Maybe (Pagelet Msg) -> Html Msg
pageletDetails pagelet
  = if pagelet == Nothing
    then div [ styleColumn 25 "#EFEFEF" ] []
    else div [ styleColumn 25 "#EFEFEF" ] []
          
workspaceDetails : Page Msg -> Html Msg
workspaceDetails page
  = article [ styleColumn 50 "white" ] <| List.concat <| List.map render page.pagelets

-- TODO: recursion
render : Pagelet Msg -> List (Html Msg)
render pagelet 
  = (.htmler <| .scrap <| pick pagelet) []

scrapsAside : List (Scrap Msg) -> Html Msg
scrapsAside scraps
  = div [ styleColumn 10 "#EEE" ] [ scrapsNav scraps ]
    
scrapsNav : List (Scrap Msg) -> Html Msg
scrapsNav scraps
  = ul [] <| List.map scrapLink scraps

scrapLink : (Scrap Msg) -> Html Msg
scrapLink scrap
  = li [] [ a [ href "#" ] [ text scrap.name ] ]
