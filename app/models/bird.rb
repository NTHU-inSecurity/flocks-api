# frozen_string_literal: true

require 'json'
require 'sequel'

module Flocks
  # Models a bird (user) in a flock
  class Bird < Sequel::Model
    many_to_one :account
    many_to_one :flock
    plugin :timestamps
    plugin :uuid, field: :id
    plugin :whitelist_security
    set_allowed_columns :message, :latitude, :longitude, :estimated_time, :account_id, :flock_id

    # Secure getters and setters
    def message
      SecureDB.decrypt(message_secure)
    end

    def message=(plaintext)
      self.message_secure = SecureDB.encrypt(plaintext)
    end

    def latitude
      lat = SecureDB.decrypt(latitude_secure)
      lat.nil? ? nil : Float(lat)
    end

    def latitude=(plaintext)
      self.latitude_secure = SecureDB.encrypt(plaintext.to_s)
    end

    def longitude
      lon = SecureDB.decrypt(longitude_secure)
      lon.nil? ? nil : Float(lon)
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
              message:,
              latitude:,
              longitude:,
              estimated_time:
            }
          },
          included: {
            flock:,
            account:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
