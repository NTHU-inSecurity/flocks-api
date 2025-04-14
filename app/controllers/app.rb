# frozen_string_literal: true

require 'roda'
require 'json'
require 'logger'

module Flocks
  # Web controller for Flocks API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'FlocksAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'flocks' do
          @flock_route = "#{@api_root}/flocks"

          routing.on String do |flock_id|
            routing.on 'birds' do
              @bird_route = "#{@api_root}/flocks/#{flock_id}/birds"
              # GET api/v1/flocks/[flock_id]/birds/[username]
              routing.get String do |username|
                bird = Bird.where(flock_id: flock_id, username: username).first
                bird ? bird.to_json : raise('Username not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/flocks/[flock_id]/birds
              routing.get do
                output = { data: Flock.first(id: flock_id).birds }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find birds'
              end

              # POST api/v1/flocks/[ID]/birds
              routing.post do
                new_data = JSON.parse(routing.body.read)
                flock = Flock.first(id: flock_id)
                new_bird = flock.add_bird(new_data)

                if new_bird
                  response.status = 201
                  response['Location'] = "#{@bird_route}/#{new_bird.id}"
                  { message: 'New bird added', data: new_bird }.to_json
                else
                  routing.halt 400, 'Could not add bird'
                end
              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/flocks/[ID]
            routing.get do
              flock = Flock.first(id: flock_id)
              flock ? flock.to_json : raise('Flock not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/flocks
          routing.get do
            output = { data: Flock.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find flocks' }.to_json
          end

          # POST api/v1/flocks
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_flock = Flock.new(new_data)
            raise('Could not save flock') unless new_flock.save_changes

            response.status = 201
            response['Location'] = "#{@flock_route}/#{new_flock.id}"
            { message: 'Flock saved', data: new_flock }.to_json
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end
      end
    end
  end
end