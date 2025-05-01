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
        routing.on 'accounts' do
          @account_route = "#{@api_root}/accounts"

          routing.on String do |email|
            # GET api/v1/accounts/[username]
            routing.get do
              account = Account.first(email:)
              account ? account.to_json : raise('Account not found')
            rescue StandardError
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # POST api/v1/accounts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = Account.new(new_data)
            raise('Could not save account') unless new_account.save_changes

            response.status = 201
            response['Location'] = "#{@account_route}/#{new_account.id}"
            { message: 'Account created', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => e
            Api.logger.error 'Unknown error saving account'
            routing.halt 500, { message: e.message }.to_json
          end
        end

        routing.on 'flocks' do # rubocop:disable Metrics/BlockLength
          @flock_route = "#{@api_root}/flocks"

          routing.on String do |flock_id| # rubocop:disable Metrics/BlockLength
            routing.on 'birds' do # rubocop:disable Metrics/BlockLength
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

          # GET api/v1/flocks
          routing.get do
            output = { data: Flock.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find data about flocks' }.to_json
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
