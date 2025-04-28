# frozen_string_literal: true

module Flocks
  # Service object to find a specific flock
  class FindFlock
    # Error for cannot find flock
    class NotFoundError < StandardError
      def message = 'Flock not found'
    end

    def self.call(id:)
      flock = Flock.first(id:)
      raise NotFoundError unless flock

      flock
    end
  end
end