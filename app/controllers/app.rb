# frozen_string_literal: true

require 'roda'
require 'json'
require 'logger'
require_relative '../helpers/symbolize_helper'

module Flocks
  # Web controller for Flocks API
  class Api < Roda
    plugin :halt
    plugin :multi_route

    route do |routing|
      response['Content-Type'] = 'application/json'

      HttpRequest.new(routing).secure? ||
        routing.halt(403, { message: 'TLS/SSL Required' }.to_json)

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
