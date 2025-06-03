# frozen_string_literal: true

module Flocks
  # Service object to update flock's destination URL
  class UpdateDestination
    # Error for unauthorized action
    class ForbiddenError < StandardError
      def message
        'You are not allowed to modify that flock'
      end
    end

    # Error for cannot find a flock
    class NotFoundError < StandardError
      def message
        'We could not find that flock'
      end
    end

    def self.call(auth:, flock_id:, new_destination:)
      flock = Flock.where(id: flock_id).first
      raise NotFoundError unless flock

      policy = FlockPolicy.new(auth.account, flock, auth.scope)
      raise ForbiddenError unless policy.can_change_destination_url?

      flock.update(destination_url: new_destination)
    end
  end
end
