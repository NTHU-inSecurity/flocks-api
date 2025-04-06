require 'json'
require 'fileutils'
require_relative '../app/models/session'

Flocks::Session.setup

session_data = {
  "members"      => ["Alice", "Bob"],
  "duration"     => 30,
  "target_address" => "1600 Amphitheatre Parkway, Mountain View, CA",
  "user_location"=> { "lat" => 37.422, "lng" => -122.084 }
}

api_key = ENV["GOOGLE_MAP_API"]

session = Flocks::Session.new(session_data, api_key)

session.save
puts "Session saved successfully!"

file_path = "#{Flocks::STORE_DIR}/#{session.session_id}.txt"
if File.exist?(file_path)
  saved_content = File.read(file_path)
  puts "Retrieved session content:"
  puts saved_content
else
  puts "Error: Could not find the saved session file."
end