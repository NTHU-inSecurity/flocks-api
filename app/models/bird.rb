# frozen_string_literal: true

require 'json'
require 'sequel'

module Flocks
  # Models a bird (user) in a flock
  class Bird < Sequel::Model
    many_to_one :account, :flock
    plugin :timestamps
    plugin :uuid, field: :id
    plugin :whitelist_security
    set_allowed_columns :username, :message, :latitude, :longitude, :estimated_time

    # Secure getters and setters
    def message
      SecureDB.decrypt(message_secure)
    end

    def message=(plaintext)
      self.message_secure = SecureDB.encrypt(plaintext)
    end

    def latitude
      Float(SecureDB.decrypt(latitude_secure))
    end

    def latitude=(plaintext)
      self.latitude_secure = SecureDB.encrypt(plaintext.to_s)
    end

    def longitude
      Float(SecureDB.decrypt(longitude_secure))
    end

    def longitude=(plaintext)
      self.longitude_secure = SecureDB.encrypt(plaintext.to_s)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'bird',
            attributes: {
              id:,
              username:,
              message:,
              latitude:,
              longitude:,
              estimated_time:
            }
          }
          # included: {
          #  flock: {
          #    id: flock.id
          #  }
          # }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
