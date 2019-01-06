{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Control.Applicative ((<|>))
import Snap.Core
        ( Method(..)
        , MonadSnap
        , ifTop
        , method
        , route
        , sendFile
        )
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
            [ ("/info", method GET showInfo)
            , ("/static", serveDirectory "static")
            ]

showInfo :: MonadSnap m => m ()
showInfo = sendFile "views/_info.html"
