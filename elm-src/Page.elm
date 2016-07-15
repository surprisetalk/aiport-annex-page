
port module Page exposing (..)

import Pagelet exposing (..)

type alias Page msg =
    { name : String
    , route : String
    , pagelets : List (Pagelet msg)
    }
    
emptyPage : Page msg
emptyPage =
    { name = ""
    , route = ""
    , pagelets = []
    }

testPages : List (Page msg)
testPages =
    [ { name = "home", route = "/", pagelets = [ testPagelet ] }
    , { name = "about", route = "/about", pagelets = [] }
    , { name = "contact", route = "/contact", pagelets = [] }
    ]
