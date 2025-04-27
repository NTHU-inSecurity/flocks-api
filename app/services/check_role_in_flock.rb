# frozen_string_literal: true

module Flocks
  # Service object to check account's role in a flock
  class CheckRole
    def self.call(account_id:, flock_id:)
      role_data = DB[:accounts_flocks_roles]
                    .where(account_id: account_id, flock_id: flock_id)
                    .join(:roles, id: :role_id)
                    .select(:name)
                    .first
      
      return nil unless role_data
      
      role_data[:name]
    end
    
    def self.is_creator?(account_id:, flock_id:)
      role = call(account_id: account_id, flock_id: flock_id)
      role == Role::CREATOR
    end
    
    def self.is_visitor?(account_id:, flock_id:)
      role = call(account_id: account_id, flock_id: flock_id)
      role == Role::VISITOR
    end
  end
end