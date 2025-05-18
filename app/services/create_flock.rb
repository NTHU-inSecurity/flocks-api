# frozen_string_literal: true

module Flocks
  class CreateFlock
    def self.call(username:, flock_data:)
      account = Account.first(username: username)
      raise 'Account not found' unless account

      # Optional bird-related fields, fallback to defaults
      latitude = flock_data.delete(:latitude) || '0.0000'
      longitude = flock_data.delete(:longitude) || '0.0000'
      message = flock_data.delete(:message) || ''

      # Create flock (remaining keys only for flock)
      flock = account.add_created_flock(flock_data)
      raise 'Could not save flock' unless flock&.save

      # Add creator as bird
      bird_data = {
        username: username,
        latitude_secure: SecureDB.encrypt(latitude),
        longitude_secure: SecureDB.encrypt(longitude),
        message_secure: SecureDB.encrypt(message),
        account_id: account.id,
        flock_id: flock.id
      }

      Flocks::Bird.new(bird_data).tap(&:save)

      flock
    end
  end
end