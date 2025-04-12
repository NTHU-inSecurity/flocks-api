# frozen_string_literal: true

require 'json'
require 'sequel'

module Flocks
  # Models a bird (user) in a flock
  class Bird < Sequel::Model
    many_to_one :flock
    plugin :timestamps
    
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
    
    # 為了向後兼容，保留 to_h 方法
    def to_h
      {
        username:,
        message:,
        latitude:,
        longitude:,
        estimated_time:
      }
    end
  end
end