{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Control.Applicative ((<|>))
import Snap.Core (ifTop, route, writeText)
import Snap.Http.Server (quickHttpServe)

main :: IO ()
main = quickHttpServe $
    ifTop (writeText "index")
    <|> route [ ("/ping", writeText "Ping") ]
    <|> writeText "Bad path"
