# frozen_string_literal: true

module Flocks
  # Get flock data
  class GetFlockQuery
    # Error for no permission
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that flock'
      end
    end

    # Error for cannot find a flock
    class NotFoundError < StandardError
      def message
        'We could not find that flock'
      end
    end

    def self.call(auth:, flock_id:)
      flock = Flock.first(id: flock_id)
      raise NotFoundError unless flock

      policy = FlockPolicy.new(auth.account, flock, auth.scope)
      raise ForbiddenError unless policy.can_view?

      flock.full_details.merge(policies: policy.summary)
    end
  end
end
