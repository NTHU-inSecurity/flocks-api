# frozen_string_literal: true

module Flocks
  class FlockPolicy
    class AccountScope
      def initialize(current_account)
        @current_account = current_account
      end

      def viewable
        # created flocks are included
        @current_account.joined_flocks
      end
    end
  end
end
