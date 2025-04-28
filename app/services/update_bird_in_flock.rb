# frozen_string_literal: true

module Flocks
  # Service object to update bird's message and location in a flock
  class UpdateBirdInFlock
    # Error for cannot find bird
    class NotFoundError < StandardError
      def message = 'Bird not found'
    end

    def self.call(flock_id:, username:, update_data:)
      bird = Bird.where(flock_id: flock_id, username: username).first
      raise NotFoundError unless bird

      bird.update(update_data)
      bird
    end
  end
end