# frozen_string_literal: true

require_relative 'add_bird_to_flock'

module Flocks
  class CreateFlock
    def self.call(username:, flock_data:)
      account = Account.first(username: username)
      raise 'Account not found' unless account

      # Create the flock
      flock = Flocks::Flock.new(flock_data)
      flock.creator = account
      raise 'Could not save flock' unless flock.save

      flock
    end
  end
end