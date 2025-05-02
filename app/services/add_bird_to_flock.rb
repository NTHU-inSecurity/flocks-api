# frozen_string_literal: true

module Flocks
  # Service object to add a new bird to a flock
  class AddBirdToFlock
    def self.call(flock_id:, bird_data:)
      Flock.where(id: flock_id).first.add_bird(bird_data)
      # CONSIDER: should add error handling?
    end
  end
end
