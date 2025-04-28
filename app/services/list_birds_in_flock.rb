# frozen_string_literal: true

module Flocks
  # Service object to list all birds in a flock
  class ListBirdsInFlock
    # Error for cannot find flock
    class NotFoundError < StandardError
      def message = 'Flock not found'
    end

    def self.call(flock_id:)
      flock = Flock.first(id: flock_id)
      raise NotFoundError unless flock

      flock.birds
    end
  end
end