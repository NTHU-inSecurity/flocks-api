# frozen_string_literal: true

module Flocks
  # Add a collaborator to another owner's existing project
  class ExitFlock
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to exit the flock'
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
      raise ForbiddenError unless policy.can_leave?

      bird = Bird.where(account_id: account.id, flock_id: flock.id)
      flock.remove_bird(bird)
      bird
    rescue StandardError
      raise 'Something went wrong when exiting the flock QQ'
    end

  end
end