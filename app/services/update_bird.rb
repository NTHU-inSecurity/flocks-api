# frozen_string_literal: true

module Flocks
  # Service object to update bird's message and location in a flock
  class UpdateBird
    # Error for cannot find bird
    class NotFoundError < StandardError
      def message = 'Bird not found'
    end

    def self.call(flock_id:, username:, new_data:)
      bird = Bird.where(flock_id: flock_id, username: username).first
      raise NotFoundError unless bird

      bird.update(new_data)
    end
  end
end
