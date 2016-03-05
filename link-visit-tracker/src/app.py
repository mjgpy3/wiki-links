#!/usr/bin/env python

from time import sleep
import pika
sleep(10)

credentials = pika.PlainCredentials('guest', 'guest')
parameters = pika.ConnectionParameters('rabbit',
                                       5672,
                                       '/',
                                       credentials)

connection = pika.BlockingConnection(parameters)
channel = connection.channel()

for method_frame, properties, body in channel.consume('linkExtracted'):
    channel.basic_ack(method_frame.delivery_tag)
