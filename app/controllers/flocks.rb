# frozen_string_literal: true

require 'roda'
require_relative 'app'

module Flocks
  # web controller for Flocks api
  class Api < Roda
    route('flocks') do |routing|
      @flock_route = "#{@api_root}/flocks"

      routing.on String do |flock_id|
        routing.on 'birds' do
          @birds_route = "#{@api_root}/flocks/#{flock_id}/birds"
          routing.on String do |bird_id|
            # POST api/v1/flocks/[ID]/birds/[ID]
            routing.post do
              new_data = JSON.parse(routing.body.read)

              updated_bird = UpdateBird.call(requestor: @auth,
                                             flock_id: flock_id,
                                             bird_id: bird_id,
                                             new_data: new_data)

              birds_data = GetBirdsQuery.call(requestor: @auth, flock_id: flock_id)
              task = LocationPublisher.new(flock_id)
              task.publish(birds_data)

              if updated_bird
                response.status = 200
                response['Location'] = "#{@birds_route}/#{updated_bird.id}"
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
            birds = GetBirdsQuery.call(requestor: @auth, flock_id: flock_id)

            if birds
              response.status = 200
              { data: birds }.to_json
            end
          rescue GetBirdsQuery::ForbiddenError => e
            puts(e.full_message)
            routing.halt 403, { message: e.message }.to_json
          rescue GetBirdsQuery::NotFoundError => e
            routing.halt 404, { message: e.message }.to_json
          rescue StandardError => e
            puts(e.full_message)
            routing.halt 404, { message: 'Could not find birds' }.to_json
          end

          # POST api/v1/flocks/[ID]/birds
          routing.post do
            AddBirdToFlock.call(
              flock_id: flock_id,
              bird_data: { account_id: @auth_account.id }
            )

            flock = GetFlockQuery.call(
              auth: @auth,
              flock_id: flock_id
            )

            response.status = 201
            response['Location'] = "#{@flock_route}/#{flock_id}"
            { data: flock }.to_json
          rescue GetFlockQuery::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue AddBirdToFlock::NotFoundError => e
            routing.halt 404, { message: e.message }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "Mass-assignment : #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            puts "FIND FLOCK ERROR: #{e.full_message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        # GET api/v1/flocks/[ID]
        routing.get do
          flock = Flock.first(id: flock_id)
          flock ? flock.to_json : raise('Flock not found')
        rescue ArgumentError
          routing.halt 404, { message: 'Invalid ID format' }.to_json
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end

        # POST api/v1/flocks/[ID]
        routing.post do
          new_data = JSON.parse(routing.body.read)
          updated_flock = UpdateDestination.call(auth: @auth,
                                                 flock_id: flock_id,
                                                 new_destination: new_data['destination_url'])
          if updated_flock
            response.status = 200
            response['Location'] = "#{@flock_route}/#{flock_id}"
            { message: 'Flock destination updated', data: updated_flock }.to_json
          end
        rescue UpdateDestination::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue UpdateDestination::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.warn "FLOCK UPDATING ERROR: #{e.message}"
          routing.halt 500, { message: 'Error updating flock' }.to_json
        end
      end

      # GET api/v1/flocks
      routing.get do
        all_flocks = FlockPolicy::AccountScope.new(@auth_account).viewable
        output = { data: all_flocks }
        JSON.pretty_generate(output)
      rescue StandardError => e
        Api.logger.warn "FLOCK RETRIEVING ERROR: #{e.message}"
        routing.halt 403, { message: 'Could not find any flocks' }.to_json
      end

      # POST api/v1/flocks
      routing.post do
        new_data = HttpRequest.new(routing).body_data

        location = RequestLatLonFromGoogle.new(new_data[:destination_url]).call
        new_flock = @auth_account.add_created_flock(new_data.merge({ latitude: location[:latitude],
                                                                     longitude: location[:longitude] }))

        AddBirdToFlock.call(
          flock_id: new_flock.id,
          bird_data: { account_id: @auth_account.id }
        )

        response.status = 201
        response['Location'] = "#{@flock_route}/#{new_flock.id}"
        { message: 'Flock saved', data: new_flock }.to_json
      rescue RequestLatLonFromGoogle::GoogleApiError => e
        Api.logger.error "GOOGLE API ERROR: #{e.message}"
        routing.halt 400, { message: 'Could not process the link' }.to_json
      rescue AddBirdToFlock::NotFoundError
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
