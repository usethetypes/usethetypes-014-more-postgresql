{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Control.Applicative ((<|>))
import Control.Monad.IO.Class (MonadIO(..))
import Data.ByteString (ByteString)
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import Database.PostgreSQL.Simple
    ( ConnectInfo
    , Connection
    , Only(..)
    , query_
    )
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
import Text.Ginger ((~>), dict)

import App.DBUtil
import App.Template

main :: IO ()
main = do
    mbPort <- lookupEnv "PORT"
    let !port = maybe 8000 read mbPort
    mbDBUrl <- lookupEnv "DATABASE_URL"
    let dbUrl = fromMaybe (error "DATABASE_URL not set") mbDBUrl
        !connInfo = fromMaybe (error "DATABASE_URL is not a valid PostgreSQL URL") (parseDBUrl dbUrl)

    let config = setPort port mempty
    httpServe config $
        ifTop (serveFile "views/index.html")
        <|> route
            [ ("/info" :: ByteString, method GET showInfo)
            , ("/users" :: ByteString, method GET (showUsers connInfo))
            , ("/static" :: ByteString, serveDirectory "static")
            ]

showInfo :: MonadSnap m => m ()
showInfo = do
    renderTemplate "views/_info.html" $ dict
        [ ("title" ~> ("Info" :: Text))
        ]

showUsers :: MonadSnap m => ConnectInfo -> m ()
showUsers connInfo = do
    userNames <- liftIO $ withDB connInfo getUserNames
    renderTemplate "views/_users.html" $ dict
        [ ("userNames" ~> userNames)
        ]

getUserNames :: Connection -> IO [String]
getUserNames conn = query_ conn "SELECT user_name FROM users" >>= pure . map fromOnly
