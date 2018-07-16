{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Snap.Core (ifTop, writeText)
import Snap.Http.Server (quickHttpServe)

main :: IO ()
main = quickHttpServe $ ifTop (writeText "Hello world")
