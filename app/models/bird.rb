# frozen_string_literal: true

module Flocks
  # Holds a single bird data
  class Bird
    def initialize(bird)
      @username = bird['username']
      @message = bird['message']
      @latitude = bird['latitude']
      @longitude = bird['longitude']
      @estimated_time = bird['estimated_time']
    end

    attr_reader :username
    attr_accessor :message, :latitude, :longitude, :estimated_time

    def to_h
      {
        username: @username,
        message: @message,
        latitude: @latitude,
        longitude: @longitude,
        estimated_time: @estimated_time
      }
    end
  end
end
