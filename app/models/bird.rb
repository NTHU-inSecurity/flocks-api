# frozen_string_literal: true

module Flocks
  # Holds a single bird data
  class Bird
    def initialize(bird)
      @username = bird['username']
      @message = bird['message']
      @estiamted_time = bird['estimated_time']
    end

    def to_h
      {
        username: @username,
        message: @message,
        estiamted_time: @estiamted_time
      }
    end
  end
end
