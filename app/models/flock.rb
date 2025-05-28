# frozen_string_literal: true

require 'json'
require 'sequel'

module Flocks
  # Models a flock (group) with destination
  class Flock < Sequel::Model
    many_to_one :creator, class: :'Flocks::Account'

    one_to_many :birds

    many_to_many :accounts, class: :'Flocks::Account',
                            join_table: :birds,
                            left_key: :flock_id, right_key: :account_id

    plugin :association_dependencies, accounts: :nullify
    plugin :timestamps
    plugin :uuid, field: :id
    plugin :whitelist_security
    set_allowed_columns :destination_url


    def to_h
      {
        type: 'flock',
        attributes: {
          id:,
          destination_url:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          creator:,
          birds:
        }
      )
    end

    def to_json(options = {})
      JSON(
        {
          type: 'flock',
          attributes: {
            id:,
            destination_url:
          }
        }, options
      )
    end
  end
end
