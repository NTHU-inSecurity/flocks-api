# frozen_string_literal: true

module Flocks
  # Service object to create a new account
  class CreateAccount
    def self.call(account_data:)
      new_account = Account.new(account_data)
      raise('Could not save account') unless new_account.save_changes

      new_account
    end
  end
end