# frozen_string_literal: true

class AddBirdToFlock
  def self.call(flock_id:, bird_data:)
    bird = Flocks::Bird.new
    bird.username = bird_data[:username]
    bird.latitude_secure = SecureDB.encrypt(bird_data[:latitude_secure])
    bird.longitude_secure = SecureDB.encrypt(bird_data[:longitude_secure])
    bird.message_secure = SecureDB.encrypt(bird_data[:message_secure] || '')
    bird.account_id = bird_data[:account_id]
    bird.flock_id = flock_id
    raise 'Could not save bird' unless bird.save
    bird
  end
end