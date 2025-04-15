# frozen_string_literal: true

require 'json'
require 'sequel'

module Flocks
  # Models a flock (group) with destination
  class Flock < Sequel::Model
    one_to_many :birds
    plugin :association_dependencies, birds: :destroy
    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'flock',
            attributes: {
              id:id ,
              destination_url:
            }
          }
        }, options
      )
    end

    private

    def new_flock_id
      timestamp = Time.now.to_f.to_s
      # compute the SHA-256 digest of the timestamp
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
    # rubocop:enable Metrics/MethodLength
  end
end