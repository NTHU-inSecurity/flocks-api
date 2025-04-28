# frozen_string_literal: true

module Flocks
  # Service object to find a specific bird in a flock
  class FindBird
    # Error for cannot find bird
    class NotFoundError < StandardError
      def message = 'Bird not found'
    end

    def self.call(flock_id:, username:)
      bird = Bird.where(flock_id: flock_id, username: username).first
      raise NotFoundError unless bird

      bird
    end
  end
end