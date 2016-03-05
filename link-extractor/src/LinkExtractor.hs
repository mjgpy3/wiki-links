{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

import Control.Lens
import Data.Aeson.Lens
import Data.Aeson
import Data.Monoid (mconcat)
import Data.Text (pack)
import Generics.Deriving
import Network.CGI
import Web.Scotty

data CreateUrlPayload =
  CreateUrlPayload { url :: String }
  deriving (Generic, Show)

instance ToJSON CreateUrlPayload

instance FromJSON CreateUrlPayload

main = scotty 3000 $ do
  post "/link" $ do
    liftIO $ putStrLn "called"
    payload <- jsonData
    liftIO $ putStrLn $ url payload
    html "<h1>Success</h1>"
