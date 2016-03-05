FROM haskell:7.10

RUN cabal update && cabal install amqp tagsoup

RUN mkdir -p /home/dev
VOLUME /home/dev

CMD ["/opt/ghc/7.10.3/bin/runhaskell", "/home/dev/link-extractor/src/LinkExtractor.hs"]
