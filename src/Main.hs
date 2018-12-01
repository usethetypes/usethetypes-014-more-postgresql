{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Control.Applicative ((<|>))
import Snap.Core (ifTop, route, writeText)
import Snap.Http.Server (quickHttpServe)
import Snap.Util.FileServe (serveFile)

main :: IO ()
main = quickHttpServe $
    ifTop (serveFile "views/index.html")
