# frozen_string_literal: true

module Flocks
  class AddBirdToFlock
    def self.call(flock_id:, bird_data:)
      bird = Flocks::Bird.new
      bird.latitude  = bird_data[:latitude]
      bird.longitude = bird_data[:longitude]
      bird.message   = bird_data[:message]
      bird.account_id = bird_data[:account_id]
      bird.flock_id   = flock_id
      raise 'Could not save bird' unless bird.save
      bird
    end
  end
end