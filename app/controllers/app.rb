# frozen_string_literal: true

require 'roda'
require 'json'
require 'logger'

require_relative '../models/flock'

module Flocks
  # Web controller for Flocks API
  class Api < Roda
    plugin :environments
    plugin :halt
    plugin :common_logger, $stderr

    # runs at application startup
    configure do
      Flock.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'FlocksAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'flocks' do
            # GET api/v1/flocks/[id]
            routing.get String do |id|
              response.status = 200
              Flock.find(id).to_json
            rescue StandardError
              routing.halt(404, { message: 'Flock not found' }.to_json)
            end

            # GET api/v1/flocks
            routing.get do
              response.status = 200
              output = { flock_ids: Flock.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/flocks
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_flock = Flock.new(new_data)

              if new_flock.save
                response.status = 201
                { Message: 'Flock data saved', id: new_flock.flock_id }.to_json
              else
                routing.halt(400, { message: 'Could not save the flock data' }.to_json)
              end
            end
          end
        end
      end
    end
  end
end
