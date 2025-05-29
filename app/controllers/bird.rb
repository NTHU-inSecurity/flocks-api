# frozen_string_literal: true

require_relative 'app'

module Flocks
  # Web controller for Credence API
  class Api < Roda
    route('bird') do |routing|
      @bird_route = "#{@api_root}/bird"

      # POST api/v1/bird/[flock_id]
      routing.on String do |flock_id|
        # either exit or delete flock
        routing.post do
          data = DeleteExitFlock.call(account: @auth_account, flock_id: flock_id)
          { data: data }.to_json
        rescue DeleteExitFlock::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue DeleteExitFlock::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end
    end
  end
end