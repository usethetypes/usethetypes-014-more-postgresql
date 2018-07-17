{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Snap.Core (writeText)
import Snap.Http.Server (quickHttpServe)

main :: IO ()
main = quickHttpServe $ writeText "Hello world"
