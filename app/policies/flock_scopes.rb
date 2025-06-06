# frozen_string_literal: true

module Flocks
  class FlockPolicy
    class AccountScope
      def initialize(current_account)
        @current_account = current_account
      end

      def viewable
        (@current_account.created_flocks + @current_account.joined_flocks).uniq
      end
    end
  end
end
