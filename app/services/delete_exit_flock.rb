# frozen_string_literal: true

module Flocks
  # delete or exit flock
  class DeleteExitFlock
    # not permission error
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

    def self.call(auth:, flock_id:)
      flock = Flock.where(id: flock_id).first
      raise NotFoundError unless flock

      policy = FlockPolicy.new(auth.account, flock, auth.scope)

      if policy.can_leave?
        bird = Bird.where(account_id: auth.account.id, flock_id: flock.id).first
        # flock.remove_bird(bird) # doing this bird.flock_id will be NULL
        bird.delete
        bird
      elsif policy.can_delete?
        flock.destroy
      else
        raise ForbiddenError
      end
    end
  end
end