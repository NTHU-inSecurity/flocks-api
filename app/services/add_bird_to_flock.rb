# frozen_string_literal: true

require_relative '../lib/secure_db'

module Flocks
  # Service object to add a new bird to a flock
  class AddBirdToFlock
    def self.call(flock_id:, bird_data:)
      flock = Flock.where(id: flock_id).first
      raise 'Flock not found' unless flock

      bird = Flocks::Bird.new
      bird.username = bird_data[:username]
      bird.latitude_secure = SecureDB.encrypt(bird_data[:latitude_secure] || '0.0000')
      bird.longitude_secure = SecureDB.encrypt(bird_data[:longitude_secure] || '0.0000')
      bird.message_secure = SecureDB.encrypt('')
      bird.account_id = bird_data[:account_id]
      bird.flock_id = flock_id
      bird.save
    end
  end
end