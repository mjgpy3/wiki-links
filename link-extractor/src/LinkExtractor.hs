#!/usr/bin/env runhaskell

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Main where

import Extraction

import Data.Aeson.Lens
import Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as BL
import Data.Traversable
import Data.Monoid (mconcat)
import Data.Text (pack, Text(..))
import Generics.Deriving
import Network.AMQP
import Network.CGI
import System.Environment
import Web.Scotty

data Payload =
  UrlContainer { url :: String }
  deriving (Generic, Show)

instance ToJSON Payload

instance FromJSON Payload

data Config =
  Config {
    appExchange :: Text
    , appOutboundQueue :: Text
    , appExchangeType :: Text
    }

config :: IO Config
config = do
  exchange <- getEnv "EXCHANGE"
  outboundQueue <- getEnv "OUTBOUND_QUEUE"
  exchangeType <- getEnv "EXCHANGE_TYPE"
  return $ Config {
    appExchange = pack exchange
    , appOutboundQueue = pack outboundQueue
    , appExchangeType = pack exchangeType
    }

main :: IO ()
main = scotty 3000 $ do
  post "/link" $ do
    payload <- jsonData
    let link = url payload
    liftIO $ extractLinks link
    html "<h1>Success</h1>"

extractLinks link = do
    links <- parseLinks link
    (Config {
      appExchange = exchange
      , appOutboundQueue = outbound
      , appExchangeType = exchType
      }) <- config
    conn <- openConnection "rabbit" "/" "guest" "guest"
    chan <- openChannel conn

    declareQueue chan newQueue { queueName = outbound }

    declareExchange chan newExchange { exchangeName = exchange, exchangeType = exchType }
    bindQueue chan outbound exchange "link.*"

    for links $ \aLink ->
      publishMsg chan exchange "link.extracted"
          (newMsg {msgBody = (encode $ UrlContainer aLink),
                   msgDeliveryMode = Just NonPersistent}
                  )

    closeConnection conn
