# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:birds) do
      uuid :id, primary_key: true
      foreign_key :flock_id, table: :flocks

      String :username, null: false, unique: true
      String :message_secure, default: ''
      String :latitude_secure, null: false 
      String :longitude_secure, null: false
      Integer :estimated_time # CONSIDER: should we secure as well?

      DateTime :created_at
      DateTime :updated_at

      unique %i[flock_id username] # make sense if you think about it
    end
  end
end
