# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative 'password'

module Flocks
  # Models a user account
  class Account < Sequel::Model
    one_to_many :created_flocks, class: :'Flocks::Flock', key: :creator_id

    many_to_many :joined_flocks, class: :'Flocks::Flock',
                                 join_table: :birds,
                                 left_key: :account_id, right_key: :flock_id

    plugin :association_dependencies,
           created_flocks: :destroy,
           joined_flocks: :nullify

    plugin :uuid, field: :id

    plugin :timestamps, update_on_create: true

    plugin :whitelist_security
    set_allowed_columns :password, :email, :username

    # Password handling
    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      password = Password.from_digest(password_digest)
      password.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            email:,
            username:
          }
        }, options
      )
    end
  end
end
