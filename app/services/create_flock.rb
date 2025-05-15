# frozen_string_literal: true

module Flocks
  # Service object to create flock by creator (single bird)
  class CreateFlock
    def self.call(username:, flock_data:)
      Account.where(username:).first.add_created_flock(flock_data)
    end
  end
end
