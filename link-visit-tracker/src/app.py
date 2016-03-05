#!/usr/bin/env python

from time import sleep
import pika
import redis

def retry(operation, interval=1):
  while True:
    try:
      r = operation()
      return r
    except:
      sleep(interval)

redis_client = retry(
  lambda:
    redis.StrictRedis(
      host='redis',
      port=6379,
      db=0
    )
)

credentials = pika.PlainCredentials(
  'guest',
  'guest'
)
parameters = pika.ConnectionParameters(
  'rabbit',
  5672,
  '/',
  credentials
)

connection = retry(
  lambda:
    pika.BlockingConnection(parameters)
)
consume = connection.channel()
consume.queue_declare(queue='linkExtracted', durable=True)

produce = connection.channel()
produce.queue_declare(queue='linkUnvisited', durable=True)

for method_frame, properties, body in consume.consume('linkExtracted'):
    consume.basic_ack(method_frame.delivery_tag)
