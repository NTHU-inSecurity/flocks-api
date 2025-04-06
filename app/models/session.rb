require 'net/http'
require 'uri'
require 'json'
require 'base64'
require 'rbnacl'

module Flocks
    STORE_DIR = 'db/local'
    END_POINT = 'https://maps.googleapis.com/maps/api/geocode/json'

    class Session
        def initialize(new_session, api_key)
            @session_id = new_session['session_id'] || new_session_id
            @members = new_session['members']
            @duration = new_session['duration']
            @target_address = new_session['target_address']
            @user_location = new_session['user_location']
            @target_location = new_session['target_location'] || new_target_location(target_address, api_key)
        end
    
        attr_reader :session_id, :members, :duration, :target_address, :user_location, :target_location

        def to_json(options = {})
            JSON(
            {
                type: 'session',
                session_id:,
                members:,
                duration:,
                target_address:,
                user_location:,
                target_location:
            },
            options
            )
        end

        def self.setup
            FileUtils.mkdir_p(Flocks::STORE_DIR)
        end

        def save
            File.write("#{Flocks::STORE_DIR}/#{session_id}.txt", to_json)
        end

        def self.find(find_id)
            file = File.read("#{Flocks::STORE_DIR}/#{session_id}.txt", to_json)
        end

        def self.all
            Dir.glob("#{Flocks::STORE_DIR}/*.txt").map do |file|
                file.match(%r{#{Regexp.quote(Flocks::STORE_DIR)}/(.*)\.txt})[1]
            end
        end

        private

        def new_session_id
            timestamp = Time.now.to_f.to_json
            Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
        end

        def new_target_location(address, api_key)
            url = URI("#{END_POINT}?address=#{URI.encode_www_form_component(address)}&key=#{api_key}")
            response = Net::HTTP.get_response(url)
            if response.code == "200"
              json = JSON.parse(response.body)
              if json["status"] == "OK"
                # Extract the first result's location coordinates.
                json["results"][0]["geometry"]["location"]
              else
                raise "Geocoding error: #{json['status']}"
              end
            else
              raise "HTTP error: #{response.code}"
            end
        end
    end
end