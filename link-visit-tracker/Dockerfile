FROM ruby:2.3.0

RUN mkdir -p /home/dev
VOLUME /home/dev

RUN gem install bunny

CMD ["/home/dev/src/app.rb"]
