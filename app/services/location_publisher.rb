# frozen_string_literal: true

require 'http'

module Flocks
  # Publishes birds' locations in the flock to Faye endpoint
  class LocationPublisher
    def initialize(channel_id)
      @config = Api.API_HOST()
      @channel_id = channel_id
    end

    def publish(message)
      puts "[post: #{@config}/faye] "
      HTTP.headers(content_type: 'application/json').post("#{@config}/faye", body: message_body(message))
    rescue HTTP::ConnectionError
      puts '(Faye server not found - progress not sent)'
    end

    private

    def message_body(message)
      { channel: "/#{@channel_id}",
        data: message }.to_json
    end
  end
end
