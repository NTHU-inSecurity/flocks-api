# frozen_string_literal: true

require 'http'

module Flocks
  class RequestLatLonFromGoogle
    class GoogleApiError < StandardError
      def message
        'Could not process location data from Google'
      end
    end

    URL = 'https://places.googleapis.com/v1/places/'

    def initialize(link)
      @link = link
    end

    def call
      response = HTTP.head(@link)

      raise GoogleApiError unless response.status.redirect?

      process_response(response.headers['Location'])
    end

    private

    def process_response(data)
      raise GoogleApiError unless data =~ /@(-?\d+\.\d+),(-?\d+\.\d+)/

      lat = ::Regexp.last_match(1)
      lng = ::Regexp.last_match(2)

      { latitude: lat.to_f, longitude: lng.to_f }
    end
  end
end
