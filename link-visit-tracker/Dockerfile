FROM python:2.7

RUN mkdir -p /home/dev
VOLUME /home/dev

RUN pip install pika
RUN pip install redis

CMD ["/home/dev/src/app.py"]
