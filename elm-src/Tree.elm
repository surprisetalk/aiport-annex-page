
port module Tree exposing (..)

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
            
