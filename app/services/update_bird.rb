# frozen_string_literal: true

module Flocks
  # Service object to update bird's message and location in a flock
  class UpdateBird

    class ForbiddenError < StandardError
      def message
        'You are not allowed to modify bird data'
      end
    end

    # Error for cannot find bird
    class NotFoundError < StandardError
      def message = 'Flock/bird not found'
    end

    def self.call(account:, flock_id:, bird_id:, new_data:)

      flock = Flock.where(id: flock_id).first
      raise NotFoundError unless flock

      policy = FlockPolicy.new(account, flock)
      raise ForbiddenError unless policy.can_view?

      bird = Bird.where(flock_id:, id: bird_id).first
      raise NotFoundError unless bird

      bird.update(latitude: new_data['latitude'],
                  longitude: new_data['longitude'],
                  message: new_data['message'])
      bird
    end
  end
end
