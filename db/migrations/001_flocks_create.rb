# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:flocks) do
      uuid :id, primary_key: true # this is flock_id

      String :destination_url
      String :entrance_ticket_secure, null: false
      String :entrance_ticket_hashed, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
