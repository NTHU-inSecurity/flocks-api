# frozen_string_literal: true

module Flocks
  # Get birds data
  class GetBirdsQuery
    # Error for no permission
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that flock data'
      end
    end

    # Error for cannot find a flock
    class NotFoundError < StandardError
      def message
        'We could not find that flock'
      end
    end

    # Birds for given requestor account
    def self.call(requestor:, flock_id:)
      flock = Flock.first(id: flock_id)
      raise NotFoundError unless flock

      policy = FlockPolicy.new(requestor, flock)
      raise ForbiddenError unless policy.can_view?

      flock.birds
    end
  end
end