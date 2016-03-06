#!/usr/bin/env ruby

require 'bunny'

sleep 10

connection = Bunny.new(host: 'rabbit')
puts 'Established connection'

connection.start

channel = connection.create_channel
inbound_queue = channel.queue('linkExtracted', durable: true)
outbound_queue = channel.queue('linkUnvisited', durable: true)

exchange = Bunny::Exchange.new(channel, :topic, 'linkExchange', durable: true)

inbound_queue.bind(exchange)
outbound_queue.bind(exchange)

inbound_queue.subscribe do |delivery_info, metadata, payload|
  puts "Received #{payload}"

  outbound_queue.publish('', routing_key: 'links.unvisited')
end

while true
  sleep 1.0
end

connection.close
