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
          # GET api/v1/flocks/[ID]/birds/[username]
          routing.get String do |username|
            # SQL injection prevention
            bird = Bird.where(flock_id: flock_id, username: username).first
            bird ? bird.to_json : raise('Username not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
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
            new_data = JSON.parse(routing.body.read)

            # FIX: if you remove this, it won't work
            acc = Account.first(email: new_data['account']['attributes']['email'])
            new_data['account'] = acc

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
            routing.halt 500, { message: 'Database error' }.to_json
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

      # GET api/v1/flocks?email=[email]
      routing.get do
        email = routing.params['email']
        account = Account.first(email: email)
        raise 'Account not found' unless account

        account_flocks = account.created_flocks

        output = { data: account_flocks }
        JSON.pretty_generate(output)
      rescue StandardError => e
        routing.halt 404, { message: e.message }.to_json
      end

      # POST api/v1/flocks?email=[email]
      routing.post do
        new_data = JSON.parse(routing.body.read).transform_keys(&:to_sym)
        email = routing.params['email']
        account = Account.where(email: email).first
        raise('Account not found') unless account
        new_flock = account.add_created_flock(new_data)
        
        raise('Could not save flock') unless new_flock.save

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