{-# OPTIONS_GHC -Wall -Werror #-}

{-# LANGUAGE OverloadedStrings #-}

module DBSetup (main) where

import Control.Monad (void)
import Control.Exception (catchJust)
import Data.Foldable (for_)
import Data.Maybe (fromMaybe)
import Database.PostgreSQL.Simple
    ( Connection
    , Only(..)
    , SqlError(..)
    , execute
    , execute_
    , query_
    )
import System.Environment (getEnv)

import App.DBUtil

main :: IO ()
main = do
    dbUrl <- getEnv "DATABASE_URL"
    let connInfo = fromMaybe
                    (error $ "Invalid database URL: " ++ dbUrl)
                    (parseDBUrl dbUrl)
    withDB connInfo $ \conn -> do
        configConnection conn
        createUsers conn
        populateUsers conn
        userNames <- getUserNames conn
        for_ userNames putStrLn

createUsers :: Connection -> IO ()
createUsers conn = void $ execute_ conn
    "CREATE TABLE IF NOT EXISTS users \
    \( id SERIAL PRIMARY KEY \
    \, user_name VARCHAR(50) UNIQUE NOT NULL \
    \);"

populateUsers :: Connection -> IO ()
populateUsers conn = for_ (["use", "the", "types"] :: [String]) $ \u -> do
    catchJust
        (\e -> if sqlState e == sqlStateUniqueViolation then Just e else Nothing)
        (void $ execute conn "INSERT INTO users (user_name) VALUES (?)" (Only u))
        (const $ pure ())

getUserNames :: Connection -> IO [String]
getUserNames conn = query_ conn "SELECT user_name FROM users" >>= pure . map fromOnly
