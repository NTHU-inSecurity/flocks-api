# frozen_string_literal: true

module Flocks
  class AddBirdToFlock
    def self.call(flock_id:, bird_data:)
      bird_data[:flock_id] = flock_id
      bird = Flocks::Bird.new(bird_data)
      raise 'Could not save bird' unless bird.save

      bird
    end
  end
end
