{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Control.Applicative ((<|>))
import qualified Data.HashMap.Strict as HashMap
import Snap.Core
        ( Method(..)
        , MonadSnap
        , ifTop
        , method
        , route
        )
import Snap.Http.Server (httpServe, setPort)
import Snap.Util.FileServe (serveDirectory, serveFile)
import System.Environment (lookupEnv)

import App.Template

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
showInfo = renderTemplate "views/_info.html" $ HashMap.fromList
            [ ("title", "Info")
            ]
