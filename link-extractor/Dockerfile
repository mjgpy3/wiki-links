FROM haskell:7.10

RUN cabal update
RUN cabal install amqp tagsoup scotty aeson lens-aeson cgi-3001.3.0.0 generic-deriving
RUN cabal install wreq

RUN mkdir -p /home/dev
VOLUME /home/dev

WORKDIR /home/dev/src

EXPOSE 3000

CMD ["/home/dev/src/LinkExtractor.hs"]
