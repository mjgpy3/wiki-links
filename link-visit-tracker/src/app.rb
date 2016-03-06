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
inbound_queue = channel.queue('linkExtracted', durable: true)
outbound_queue = channel.queue('linkUnvisited', durable: true)

exchange = Bunny::Exchange.new(channel, :topic, 'linkExchange', durable: true)

inbound_queue.bind(exchange)
outbound_queue.bind(exchange)

inbound_queue.subscribe do |delivery_info, metadata, payload|
  puts "Received #{payload}"

  json = JSON.parse(payload)

  if !redis.sismember('visited_urls', json['url'])
    outbound_queue.publish(
      payload,
      routing_key: 'links.unvisited'
    )
  end

  redis.sadd('visited_urls', json['url'])
end

while true
  sleep 1.0
end

connection.close
