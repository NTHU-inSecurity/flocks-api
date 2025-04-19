# frozen_string_literal: true

require 'json'
require 'sequel'

module Flocks
  # Models a flock (group) with destination
  class Flock < Sequel::Model
    one_to_many :birds
    plugin :association_dependencies, birds: :destroy
    plugin :timestamps

    # white list of attributes
    plugin :whitelist_security

    # whitelist the attributes we want to allow
    set_allowed_columns :destination_url

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'flock',
            attributes: {
              id: id,
              destination_url:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
