{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

import Control.Lens
import Data.Aeson.Lens
import Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as BL
import Data.Monoid (mconcat)
import Data.Text (pack)
import Generics.Deriving
import Network.AMQP
import Network.CGI
import Web.Scotty

data CreateUrlPayload =
  CreateUrlPayload { url :: String }
  deriving (Generic, Show)

instance ToJSON CreateUrlPayload

instance FromJSON CreateUrlPayload

main :: IO ()
main = scotty 3000 $ do
  post "/link" $ do
    payload <- jsonData
    liftIO $ putStrLn $ url payload
    liftIO foobar
    html "<h1>Success</h1>"

foobar = do
    conn <- openConnection "rabbit" "/" "guest" "guest"
    chan <- openChannel conn

    declareQueue chan newQueue { queueName = "linkExtracted" }

    declareExchange chan newExchange { exchangeName = "linkExchange", exchangeType = "topic" }
    bindQueue chan "linkExtracted" "linkExchange" "link.*"

    publishMsg chan "linkExchange" "link.extracted"
        (newMsg {msgBody = (BL.pack "Hi there"),
                 msgDeliveryMode = Just NonPersistent}
                )

    closeConnection conn
