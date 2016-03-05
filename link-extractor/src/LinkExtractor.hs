{-# LANGUAGE OverloadedStrings #-}

import Web.Scotty
import Data.Monoid (mconcat)
import Network.CGI

main = scotty 3000 $ do
  post "/link" $ do
    liftIO $ putStrLn "called"
    body <- body
    html "<h1>Hi there</h1>"
