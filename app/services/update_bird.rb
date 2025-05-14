# frozen_string_literal: true

module Flocks
  # Service object to update bird's message and location in a flock
  class UpdateBird
    # Error for cannot find bird
    class NotFoundError < StandardError
      def message = 'Bird not found'
    end

    def self.call(flock_id:, username:, new_data:)
      bird = Bird.where(flock_id:, username:).first
      raise NotFoundError unless bird

      bird.update(latitude: new_data['latitude'],
                  longitude: new_data['longitude'],
                  message: new_data['message'])
      bird
    end
  end
end
