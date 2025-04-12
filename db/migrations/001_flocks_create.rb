require 'sequel'

Sequel.migration do
    change do
        create_table(:flocks) do
            primary_key :id # this is flock_id

            # String :flock_id, null: false, unique: true
            String :destination_url, null: false

            DateTime :created_at
            DateTime :updated_at
        end
    end
end
