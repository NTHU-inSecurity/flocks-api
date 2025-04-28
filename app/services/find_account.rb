# frozen_string_literal: true

module Flocks
  # Service object to find a specific account
  class FindAccount
    # Error for cannot find account
    class NotFoundError < StandardError
      def message = 'Account not found'
    end

    def self.call(username:)
      account = Account.first(username:)
      raise NotFoundError unless account

      account
    end
  end
end