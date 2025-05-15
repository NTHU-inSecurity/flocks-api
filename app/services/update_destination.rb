# frozen_string_literal: true

module Flocks
  # Service object to update flock's destination URL
  class UpdateDestination
    # Error for unauthorized action
    class UnauthorizedError < StandardError
      def message = 'Only creators may update destination'
    end

    def self.call(username:, flock_id:, new_destination:)
      # check: whether account is creator in flock?
      is_creator = Account.where(username:).first
      flock = Flock.where(id: flock_id).first
      raise(UnauthorizedError) if flock.creator_id != is_creator.id

      flock.update(destination_url: new_destination)
    end
  end
end
