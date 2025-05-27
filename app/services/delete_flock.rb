# frozen_string_literal: true

module Flocks
  # Service object to update flock's destination URL
  class DeleteFlock
    # Error for unauthorized action
    class ForbiddenError < StandardError
      def message
        'You are not allowed to delete that flock'
      end
    end

    # Error for cannot find a flock
    class NotFoundError < StandardError
      def message
        'We could not find that flock'
      end
    end

    def self.call(account:, flock_id:)
      flock = Flock.where(id: flock_id).first
      raise NotFoundError unless flock

      policy = FlockPolicy.new(account, flock)
      raise ForbiddenError unless policy.can_delete?

      flock.destroy
    end
  end
end
