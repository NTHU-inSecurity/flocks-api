# frozen_string_literal: true

module Flocks
  # Service object to create flock by creator (single bird)
  class CreateFlock
    def self.call(email:, flock_data:)
      Account.where(email: email).first.add_created_flock(flock_data)
    end
  end
end
