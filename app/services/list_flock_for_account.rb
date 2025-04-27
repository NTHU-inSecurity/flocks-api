# frozen_string_literal: true

module Flocks
  # Service object to list all flocks for an account
  class ListFlocksForAccount
    def self.call(account_id:)
      flock_ids = DB[:accounts_flocks_roles]
                   .where(account_id: account_id)
                   .select(:flock_id)
                   .map(:flock_id)
      
      Flock.where(id: flock_ids).all
    end
  end
end