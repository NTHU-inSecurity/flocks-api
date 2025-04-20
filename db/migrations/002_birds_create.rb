# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:birds) do
      uuid :id, primary_key: true
      foreign_key :flock_id, table: :flocks

      String :username, null: false, unique: true
      String :message
      Float :latitude
      Float :longitude
      Integer :estimated_time

      DateTime :created_at
      DateTime :updated_at

      unique %i[flock_id username] # make sense if you think about it
    end
  end
end
