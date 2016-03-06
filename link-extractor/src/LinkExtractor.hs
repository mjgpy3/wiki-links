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
import Data.Text (pack)
import Generics.Deriving
import Network.AMQP
import Network.CGI
import Web.Scotty

data Payload =
  UrlContainer { url :: String }
  deriving (Generic, Show)

instance ToJSON Payload

instance FromJSON Payload

main :: IO ()
main = scotty 3000 $ do
  post "/link" $ do
    payload <- jsonData
    let link = url payload
    liftIO $ extractLinks link
    html "<h1>Success</h1>"

extractLinks link = do
    links <- parseLinks link
    putStrLn "Printing"
    print links
    putStrLn "/Printing"
    conn <- openConnection "rabbit" "/" "guest" "guest"
    chan <- openChannel conn

    declareQueue chan newQueue { queueName = "linkExtracted" }

    declareExchange chan newExchange { exchangeName = "linkExchange", exchangeType = "topic" }
    bindQueue chan "linkExtracted" "linkExchange" "link.*"

    for links $ \aLink ->
      publishMsg chan "linkExchange" "link.extracted"
          (newMsg {msgBody = (encode $ UrlContainer aLink),
                   msgDeliveryMode = Just NonPersistent}
                  )

    closeConnection conn
