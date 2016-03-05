FROM haskell:7.10

RUN cabal update && cabal install amqp tagsoup
RUN cabal install scotty
RUN cabal install aeson lens-aeson
RUN cabal install cgi-3001.3.0.0

RUN mkdir -p /home/dev
VOLUME /home/dev

EXPOSE 3000

CMD ["/opt/ghc/7.10.3/bin/runhaskell", "/home/dev/src/LinkExtractor.hs"]
