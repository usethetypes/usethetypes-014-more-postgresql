module App.Template
    ( renderTemplate
    ) where

import Data.HashMap.Strict (HashMap)
import Data.Text (Text)
import Snap.Core (MonadSnap, sendFile)

type Context = HashMap Text Text

renderTemplate :: MonadSnap m => FilePath -> Context -> m ()
renderTemplate path _ = sendFile path
