# frozen_string_literal: true

require 'json'
require 'sequel'

module Flocks
  # Models a role for access control
  class Role < Sequel::Model
    CREATOR = 'creator'
    VISITOR = 'visitor'
    
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name
    
    # Check if role is creator
    def creator?
      name == CREATOR
    end
    
    # Check if role is visitor
    def visitor?
      name == VISITOR
    end
    
    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'role',
            attributes: {
              id:,
              name:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end