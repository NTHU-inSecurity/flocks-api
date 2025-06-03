# frozen_string_literal: true

require 'roda'
require 'json'
require 'logger'
require_relative '../helpers/symbolize_helper'

require_relative 'http_request'

module Flocks
  # Web controller for Flocks API
  class Api < Roda
    plugin :halt
    plugin :multi_route
    plugin :request_headers

    UNAUTH_MSG = { message: 'Unauthorized Request' }.to_json

    route do |routing|
      response['Content-Type'] = 'application/json'

      request = HttpRequest.new(routing)

      request.secure? ||
        routing.halt(403, { message: 'TLS/SSL Required' }.to_json)

      begin
        @auth = request.authorized_account
        @auth_account = @auth.account if @auth
      rescue AuthToken::InvalidTokenError
        routing.halt 403, { message: 'Invalid auth token' }.to_json
      rescue AuthToken::ExpiredTokenError
        routing.halt 403, { message: 'Expired auth token' }.to_json
      end

      routing.root do
        { message: 'FlocksAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.multi_route
      end
    end
  end
end
