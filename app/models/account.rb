# frozen_string_literal: true

require 'json'
require 'sequel'

module Flocks
  # Models a user account
  class Account < Sequel::Model
    one_to_many :birds
    
    plugin :timestamps
    plugin :uuid, field: :id
    plugin :whitelist_security
    set_allowed_columns :username, :password
    
    # Password handling
    def password=(new_password)
      self.password_digest = SecureDB.encrypt(new_password)
    end
    
    def password?(try_password)
      try_password_encrypted = SecureDB.encrypt(try_password)
      try_password_encrypted == password_digest
    end
    
    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'account',
            attributes: {
              id:,
              username:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end