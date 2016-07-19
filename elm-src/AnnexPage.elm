
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
    , workspace : 
      { hoverscrap : Maybe (Scrap Msg)
      , overpagelets : List (Scrap Msg)
      , page : Maybe (Page Msg)
      , pagelet : Maybe (Pagelet Msg)
      }
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
= "http://taysar.com:9097/"
    

-- UPDATE

-- TODO: Scrap needs to change to function

type Msg
  = SelectPage (Page Msg)
  | SelectPagelet (Pagelet Msg)
  | UpdatePage (Page Msg)
  | UpdatePageName String
  | UpdatePageRoute String
  | SavePage (Page Msg)
  | SavePagelet (Pagelet Msg)
  | DragScrap (Scrap Msg) 
  | DropScrap (Scrap Msg)
  | MouseEnterPagelet (Pagelet Msg) 
  | MouseLeavePagelet (Pagelet Msg)
  | HttpSucceedSavePage (Html Msg)
  | HttpSucceedFetchPages (List (Page Msg))
  | HttpSucceedFetchScraps (List (Html Msg))
  | HttpFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SelectPage page ->
      ({ model | page = page }, Cmd.none)
    SelectPagelet pagelet ->
        let 
            workspace = model.workspace
        in 
            ({ model | workspace = { workspace | pagelet = pagelet } }, Cmd.none)
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
            page = model.workspace.page
        in 
            ({ model | workspace = { workspace | page = { page | name = name } } }, Cmd.none)
    UpdatePageRoute route ->
        let 
            workspace = model.workspace
            page = model.workspace.page
        in 
            ({ model | workspace = { workspace | page = { page | route = route } } }, Cmd.none)
    SavePage page ->
        let 
            saver
            = Task.perform HttpFail HttpSucceedSavePage 
              <| Http.post 
              <| Json.succeed Nothing
              |> localhost ++ "pile/page" 
              -- TODO: { _id: null, pagelet_id: null, name: null, route: null }
              <| Http.empty
        in
            (model, saver)
    SavePagelet pagelet ->
        let 
            saver
            = Task.perform HttpFail HttpSucceedSavePagelet
              <| Http.post 
              <| Json.succeed Nothing
              |> localhost ++ "pile/pagelet" 
              -- TODO: { _id: null, pagelet_ids: null, scrap_id: null, options: {} }
              <| Http.empty
        in
            (model, saver)
    DragScrap scrap ->
        let 
            workspace = model.workspace
        in 
            ({ model | workspace = { workspace | hoverscrap = scrap } }, Cmd.none)
    DropScrap scrap ->
        case overpagelets of model.workspace.overpagelets
            [] ->
                (model, Cmd.none)
            overpagelet::_ ->
                let 
                    workspace = model.workspace
                in 
                    ({ model | workspace = { workspace | hoverscrap = Nothing, pagelet = Pagelet.setScrap overpagelet scrap } }, Cmd.none)
    MouseEnterPagelet pagelet ->
        case maybescrap of model.workspace.hoverscrap
            Nothing ->
                ({ model | workspace = { model.workspace | overpagelets = pagelet :: model.workspace.overpagelets } }, Cmd.none)
            Just hoverscrap ->
                ({ model | workspace = { model.workspace | overpagelets = pagelet :: model.workspace.overpagelets, pagelet = pagelet } }, Cmd.none)
    MouseLeavePagelet pagelet ->
        ({ model | workspace = { model.workspace | overpagelets = filter (!= pagelet) model.workspace.overpagelets } }, Cmd.none)
    -- KLUDGE: shouldn't be chaining the commands like this
    HttpSucceedSavePage page ->
        ({ model | workspace = { model.workspace | page = page } }, Debug.log "FetchPageSucceed" Cmd.none)
    HttpSucceedSavePagelet page ->
        ({ model | workspace = { model.workspace | pagelet = pagelet } }, Debug.log "FetchPageSucceed" Cmd.none)
    HttpSucceedFetchPages pages ->
        ({ model | pages = pages }, Debug.log "FetchPageSucceed" Cmd.none)
    HttpSucceedFetchScraps htmls ->
        ({ model | workspace = div [ styleColumn 50 "white" ] htmls }, Debug.log "FetchScrapSucceed" Cmd.none)
    HttpFail error ->
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

-- TODO: subscribe to pages
-- TODO: subscribe to scraps
-- TODO: subscribe to mouse down

-- VIEW

-- TODO: all this crap
-- TODO: remember that scraps are supposed to be functions that generate html blah blah blah
