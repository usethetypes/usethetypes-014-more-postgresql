{-# LANGUAGE OverloadedStrings #-}

module App.Template
    ( renderTemplate
    ) where

import Control.Monad.IO.Class (MonadIO(..))
import Control.Monad.Trans.Writer (Writer)
import Data.Text (Text)
import Snap.Core (MonadSnap, modifyResponse, setHeader, setResponseCode, writeText)
import System.IO.Error (tryIOError)
import Text.Ginger (GVal, Run, SourcePos, easyRender, parseGingerFile)

type Context = GVal (Run SourcePos (Writer Text) Text)

resolve :: FilePath -> IO (Maybe String)
resolve path = do
    mbContents <- tryIOError $ readFile path
    case mbContents of
        Right contents -> pure $ Just contents
        Left e -> print e >> pure Nothing

renderTemplate :: MonadSnap m => FilePath -> Context -> m ()
renderTemplate path ctx = do
    result <- liftIO $ parseGingerFile resolve path
    case result of
        Left e -> do
            liftIO $ print e
            modifyResponse $ setResponseCode 500
        Right template -> do
            modifyResponse $ setHeader "Content-Type" "text/html"
            writeText $ easyRender ctx template
