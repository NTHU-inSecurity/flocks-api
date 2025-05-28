# frozen_string_literal: true

module Flocks
  class AddBirdToFlock
    # Error for cannot find a flock
    class NotFoundError < StandardError
      def message
        'We could not find that flock'
      end
    end

    def self.call(flock_id:, bird_data:)
      flock = Flock.first(id: flock_id)
      raise NotFoundError unless flock

      flock.add_bird(bird_data)
    end
  end
end
