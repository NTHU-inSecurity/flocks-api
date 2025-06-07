# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:flocks) do
      uuid :id, primary_key: true # this is flock_id
      foreign_key :creator_id, :accounts, type: :uuid

      String :destination_url
      Float :latitude
      Float :longitude

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
