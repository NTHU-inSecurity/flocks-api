# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:birds) do
      uuid :id, primary_key: true
      foreign_key :flock_id, table: :flocks, null: false, type: :uuid
      foreign_key :account_id, table: :accounts, null: false, type: :uuid

      String :message_secure
      String :latitude_secure
      String :longitude_secure
      Integer :estimated_time # CONSIDER: should we secure as well?

      DateTime :created_at
      DateTime :updated_at

      unique %i[flock_id account_id]
    end
  end
end
