# frozen_string_literal: true

module Flocks
  # Service object to assign a role to an account in a flock
  class AssignRole
    # Error for unauthorized action
    class UnauthorizedError < StandardError
      def message = 'Only creators can assign roles'
    end
    
    def self.call(assigner_account_id:, flock_id:, account_id:, role_name:)
      is_creator = DB[:accounts_flocks_roles]
                     .where(account_id: assigner_account_id, 
                            flock_id: flock_id)
                     .join(:roles, id: :role_id)
                     .where(name: Role::CREATOR)
                     .count > 0
      
      raise UnauthorizedError unless is_creator
      
      role = Role.first(name: role_name)
      raise('Role not found') unless role
      
      existing = DB[:accounts_flocks_roles]
                   .where(account_id: account_id, flock_id: flock_id)
                   .first
      
      if existing
        DB[:accounts_flocks_roles]
          .where(account_id: account_id, flock_id: flock_id)
          .update(role_id: role.id)
      else
        DB[:accounts_flocks_roles].insert(
          account_id: account_id,
          flock_id: flock_id,
          role_id: role.id
        )
      end
      
      { success: true }
    end
  end
end