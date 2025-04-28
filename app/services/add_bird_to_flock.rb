# frozen_string_literal: true

module Flocks
  # Service object to add a new bird to a flock
  class AddBirdToFlock
    def self.call(flock_id:, bird_data:)
      flock = Flock.first(id: flock_id)
      raise('Flock not found') unless flock

      new_bird = flock.add_bird(bird_data)
      raise('Could not save bird') unless new_bird

      new_bird
    end
  end
end