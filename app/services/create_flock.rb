# frozen_string_literal: true

require_relative 'add_bird_to_flock'

module Flocks
  class CreateFlock
    def self.call(username:, flock_data:)
      account = Account.first(username: username)
      raise 'Account not found' unless account

      # Optional bird-related fields
      # ASK: why would you put it here, it's waste of space
      latitude  = flock_data.delete(:latitude)  || '0.0000'
      longitude = flock_data.delete(:longitude) || '0.0000'
      message   = flock_data.delete(:message)   || ''

      # Create the flock
      flock = Flocks::Flock.new(destination_url: flock_data[:destination_url])
      flock.creator = account
      raise 'Could not save flock' unless flock.save

      # Delegate bird creation to AddBirdToFlock
      bird_data = {
        latitude: latitude,
        longitude: longitude,
        message: message,
        account_id: account.id
      }

      Flocks::AddBirdToFlock.call(flock_id: flock.id, bird_data: bird_data)

      flock
    end
  end
end
