FROM node:4.3.2

RUN mkdir /home/dev
WORKDIR /home/dev

VOLUME /home/dev

RUN npm install jquery
RUN npm install express

EXPOSE 3001

CMD ["/home/dev/src/app.js"]
