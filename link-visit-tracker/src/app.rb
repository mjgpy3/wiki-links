#!/usr/bin/env ruby

require 'bunny'
require 'json'
require 'redis'

connection = Bunny.new(host: 'rabbit')

begin
  connection.start
rescue
  sleep 1.0
  retry
end

begin
  redis = Redis.new(host: 'redis')
rescue
  sleep 1.0
  retry
end

puts 'Established connection'

channel = connection.create_channel
inbound_queue = channel.queue(ENV['INBOUND_QUEUE'], durable: true)
outbound_queue = channel.queue(ENV['OUTBOUND_QUEUE'], durable: true)

exchange = Bunny::Exchange.new(channel, ENV['EXCHANGE_TYPE'].to_sym, ENV['EXCHANGE'], durable: true)

inbound_queue.bind(exchange)
outbound_queue.bind(exchange)

VISITED_SET_NAME = ENV['VISITED_SET_NAME']

inbound_queue.subscribe do |delivery_info, metadata, payload|
  puts "Received #{payload}"

  json = JSON.parse(payload)

  if !redis.sismember(VISITED_SET_NAME, json['url'])
    outbound_queue.publish(
      payload,
      routing_key: 'links.unvisited'
    )
  end

  redis.sadd(VISITED_SET_NAME, json['url'])
end

while true
  sleep 1.0
end

connection.close
