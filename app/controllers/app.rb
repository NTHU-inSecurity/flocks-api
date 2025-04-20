# frozen_string_literal: true

require 'roda'
require 'json'
require 'logger'

module Flocks
  # Web controller for Flocks API
  class Api < Roda
    plugin :halt

    # add logger
    class << self
      def logger
        @logger ||= Logger.new($stderr)
      end
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'FlocksAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do # rubocop:disable Metrics/BlockLength
        routing.on 'flocks' do # rubocop:disable Metrics/BlockLength
          @flock_route = "#{@api_root}/flocks"

          routing.on String do |flock_id| # rubocop:disable Metrics/BlockLength
            routing.on 'birds' do # rubocop:disable Metrics/BlockLength
              @bird_route = "#{@api_root}/flocks/#{flock_id}/birds"
              # GET api/v1/flocks/[flock_id]/birds/[username]
              routing.get String do |username|
                # SQL injection prevention :use parameters to search
                bird = Bird.where(flock_id: flock_id).where(Sequel.lit('username = ?', username)).first
                bird ? bird.to_json : raise('Username not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              routing.get do
                # SQL injection prevention :check ID for validity
                flock_id_i = Integer(flock_id, 10)
                output = { data: Flock.first(id: flock_id_i).birds }
                JSON.pretty_generate(output)
              rescue ArgumentError
                routing.halt 404, { message: 'Invalid ID format' }.to_json
              rescue StandardError
                routing.halt 404, { message: 'Could not find birds' }.to_json
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
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "Mass-assignment : #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/flocks/[ID]
            routing.get do
              # SQL injection prevention :check ID for validity and transform to integer
              flock_id_i = Integer(flock_id, 10)
              flock = Flock.first(id: flock_id_i)
              flock ? flock.to_json : raise('Flock not found')
            rescue ArgumentError
              routing.halt 404, { message: 'Invalid ID format' }.to_json
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
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 500, { message: 'Unknown server error' }.to_json
          end
        end
      end
    end
  end
end
