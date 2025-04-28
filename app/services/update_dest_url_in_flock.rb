# frozen_string_literal: true

module Flocks
  # Service object to update flock's destination URL
  class UpdateFlockDestination
    # Error for unauthorized action
    class UnauthorizedError < StandardError
      def message = 'Only creators can update destination'
    end
    
    def self.call(account_id:, flock_id:, new_destination_url:)
      # check: whether account is creator in flock?
      is_creator = CheckRole.is_creator?(account_id: account_id, flock_id: flock_id)
      raise UnauthorizedError unless is_creator
      
      flock = Flock.first(id: flock_id)
      raise('Flock not found') unless flock
      
      flock.update(destination_url: new_destination_url)
      flock
    end
  end
end