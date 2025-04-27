# frozen_string_literal: true

module Flocks
  # Service object to create a new flock with creator
  class CreateFlock
    def self.call(account_id:, flock_data:)

      Flock.db.transaction do
        new_flock = Flock.new(flock_data)
        raise('Could not save flock') unless new_flock.save_changes
        
        creator_role = Role.first(name: Role::CREATOR)
        raise('Creator role not found') unless creator_role
        
        DB[:accounts_flocks_roles].insert(
          account_id: account_id,
          flock_id: new_flock.id,
          role_id: creator_role.id
        )
        
        new_flock
      end
    end
  end
end