# frozen_string_literal: true

require 'json'
require 'sequel'

module Flocks
  # Models a flock (group) with destination
  class Flock < Sequel::Model
    one_to_many :birds
    plugin :association_dependencies, birds: :destroy
    plugin :timestamps
    plugin :uuid, field: :id
    plugin :whitelist_security
    set_allowed_columns :destination_url

    def initialize(values={})
      super
      ticket = SecureDB.generate_ticket
      self.entrance_ticket_secure = SecureDB.encrypt(ticket)
      self.entrance_ticket_hashed = SecureDB.hash_ticket(ticket)
    end

    def entrance_ticket
      SecureDB.decrypt(entrance_ticket_secure)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'flock',
            attributes: {
              id:,
              destination_url:,
              entrance_ticket:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
