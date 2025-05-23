# frozen_string_literal: true

require 'roda'
require_relative 'app'

module Flocks
  # web controller for Flocks api
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('flocks') do |routing|
      @flock_route = "#{@api_root}/flocks"

      routing.on String do |flock_id|
        routing.on 'birds' do
          @bird_route = "#{@api_root}/flocks/#{flock_id}/birds"

          routing.on String do |bird_id|
            # GET api/v1/flocks/[ID]/birds/[ID]
            routing.get do
              # SQL injection prevention
              bird = Bird.where(flock_id: flock_id, id: bird_id).first
              bird ? bird.to_json : raise('Bird not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end

            # POST api/v1/flocks/[ID]/birds/[ID]
            routing.post do
              new_data = JSON.parse(routing.body.read)

              updated_bird = UpdateBird.call(flock_id: flock_id,
                                             bird_id: bird_id,
                                             new_data: new_data)

              if updated_bird
                response.status = 200
                response['Location'] = "#{@bird_route}/#{updated_bird.id}"
                { message: 'Bird data updated', data: updated_bird }.to_json
              else
                routing.halt 400, 'Could not update bird data'
              end
            rescue Sequel::MassAssignmentRestriction
              Api.logger.warn "Mass-assignment : #{new_data.keys}"
              routing.halt 400, { message: 'Illegal Attributes' }.to_json
            rescue StandardError
              routing.halt 500, { message: 'Database error' }.to_json
            end
          end

          # GET api/v1/flocks/[ID]/birds
          routing.get do
            # SQL injection prevention
            output = { data: Flock.first(id: flock_id).birds }
            JSON.pretty_generate(output)
          rescue ArgumentError
            routing.halt 404, { message: 'Invalid ID format' }.to_json
          rescue StandardError
            routing.halt 404, { message: 'Could not find birds' }.to_json
          end

          # POST api/v1/flocks/[ID]/birds
          routing.post do
            new_data = Flocks::Helper.deep_symbolize(JSON.parse(routing.body.read))
            acc = Account.first(username: new_data[:account][:attributes][:username])
            new_data[:account_id] = acc.id
            new_data.delete(:account)

            new_bird = AddBirdToFlock.call(flock_id: flock_id, bird_data: new_data)

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
            routing.halt 500, { message: 'Database error: ' }.to_json
          end
        end

        # GET api/v1/flocks/[ID]
        routing.get do
          # SQL injection prevention
          flock = Flock.first(id: flock_id)
          flock ? flock.to_json : raise('Flock not found')
        rescue ArgumentError
          routing.halt 404, { message: 'Invalid ID format' }.to_json
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # GET api/v1/flocks
      routing.get do
        username = @auth_account['username']
        account = Account.first(username: username)
        raise 'Account not found' unless account

        all_flocks = Flocks::Bird.where(account_id: account.id).map(&:flock)
        output = { data: all_flocks }
        JSON.pretty_generate(output)
      rescue StandardError => e
        routing.halt 404, { message: e.message }.to_json
      end

      # POST api/v1/flocks
      routing.post do
        new_data = Flocks::Helper.deep_symbolize(JSON.parse(routing.body.read))
        username = @auth_account['username']

        # Reject illegal mass-assignment attempts from API input
        # ASK: why the fuck is it here
        rejected_keys = %i[created_at updated_at id account_id flock_id]
        routing.halt 400, { message: 'Illegal Attributes' }.to_json if new_data.keys.intersect?(rejected_keys)

        new_flock = Flocks::CreateFlock.call(username: username, flock_data: new_data)

        response.status = 201
        response['Location'] = "#{@flock_route}/#{new_flock.id}"
        { message: 'Flock saved', data: new_flock }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Attributes' }.to_json
      rescue StandardError => e
        Api.logger.error "UNKNOWN ERROR: #{e.message}"
        routing.halt 500, { message: 'Unknown server error' }.to_json
      end
    end
  end
end
