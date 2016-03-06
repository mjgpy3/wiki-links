module Extraction (parseLinks) where

import qualified Data.ByteString.Lazy.Char8 as BS
import Data.Maybe
import Control.Lens
import qualified Network.Wreq as Wreq
import Text.HTML.TagSoup

rawHtml :: String -> IO String
rawHtml link = do
  response <- Wreq.get link
  return $ BS.unpack $ response ^. Wreq.responseBody

links :: String -> [String]
links html =
  let
    attributes (TagOpen _ attr) = attr
    tags = parseTags html
    anchorTags = filter (~== "<a>") tags
    links = catMaybes $ map (lookup "href" . attributes) anchorTags
  in
    links

parseLinks :: String -> IO [String]
parseLinks url = do
  html <- rawHtml url
  return $ links html
