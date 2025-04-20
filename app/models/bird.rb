# frozen_string_literal: true

require 'json'
require 'sequel'

module Flocks
  # Models a bird (user) in a flock
  class Bird < Sequel::Model
    many_to_one :flock
    plugin :timestamps
    plugin :uuid, field: :id

    # white list of attributes
    plugin :whitelist_security

    # whitelist the attributes we want to allow
    set_allowed_columns :username, :message, :latitude, :longitude, :estimated_time, :flock_id

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
          },
          included: {
            flock:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
