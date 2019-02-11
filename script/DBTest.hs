{-# OPTIONS_GHC -Wall -Werror #-}

{-# LANGUAGE OverloadedStrings #-}

module DBTest (main) where

import qualified Data.ByteString.Char8 as Char8 (pack)
import Database.PostgreSQL.Simple
    ( Only(..)
    , close
    , connectPostgreSQL
    , query_
    )
import System.Environment (getEnv)

main :: IO ()
main = do
    dbUrl <- getEnv "DATABASE_URL"
    conn <- connectPostgreSQL (Char8.pack dbUrl)
    [Only result] <- query_ conn "SELECT 'Hello' || ' ' || 'world'"
    print (result :: String)
    close conn
