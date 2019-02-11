{-# OPTIONS_GHC -Wall -Werror #-}

{-# LANGUAGE OverloadedStrings #-}

module App.DBUtil
    ( configConnection
    , parseDBUrl
    , sqlStateUniqueViolation
    , withDB
    ) where

import Control.Exception (bracket)
import Control.Monad (void)
import Data.ByteString (ByteString)
import Database.PostgreSQL.Simple
    ( ConnectInfo(..)
    , Connection
    , close
    , connect
    , execute_
    )
import Text.Read (readMaybe)
import Text.Regex.Posix ((=~))

configConnection :: Connection -> IO ()
configConnection conn = void $ execute_ conn "SET client_min_messages = error;"

sqlStateUniqueViolation :: ByteString
sqlStateUniqueViolation = "23505"

parseDBUrl :: String -> Maybe ConnectInfo
parseDBUrl s =
    let pat :: String
        pat = "^postgres://([^:]+):([^@]+)@([^:]+):([0-9]+)/(.+)$"
    in case (s =~ pat :: (String, String, String, [String])) of
        (_, _, _, [user, password, host, portStr, dbName]) ->
            case readMaybe portStr of
                Just port -> Just $ ConnectInfo host port user password dbName
                _ -> Nothing
        _ -> Nothing

-- There is a connectPostgreSQL which would take the database URL directly
-- However, I like to get my strings into a strongly typed data structures
-- as soon as possible.
withDB :: ConnectInfo -> (Connection -> IO a) -> IO a
withDB connInfo = bracket (connect connInfo) close
