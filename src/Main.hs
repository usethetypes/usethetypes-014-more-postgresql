{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Control.Applicative ((<|>))
import Snap.Core (ifTop, route)
import Snap.Http.Server (httpServe, setPort)
import Snap.Util.FileServe (serveDirectory, serveFile)
import System.Environment (lookupEnv)

main :: IO ()
main = do
    mbPort <- lookupEnv "PORT"
    let port = maybe 8000 read mbPort
        config = setPort port mempty
    httpServe config $
        ifTop (serveFile "views/index.html")
        <|> route
            [ ("/static", serveDirectory "static")
            ]
