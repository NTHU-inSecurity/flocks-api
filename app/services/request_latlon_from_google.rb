# frozen_string_literal: true

require 'http'

module Flocks
  class RequestLatLonFromGoogle
    class GoogleApiError < StandardError
      def message
        'Could not process location data from Google'
      end
    end

    URL = 'https://maps.googleapis.com/maps/api/geocode/json'

    def initialize(link)
      @link = link
      @key = Api.GEO_KEY
    end

    def call
      response = HTTP.head(@link)

      raise GoogleApiError unless response.status.redirect?

      process_response(response.headers['Location'])
    end

    private

    def process_response(data)
      address = data[%r{(?<=place/)[^/]+(?=/@)}]
      raise GoogleApiError unless data

      response = HTTP.get(URL, params: { address: address, key: @key })

      raise GoogleApiError unless response.status.success?

      results = JSON.parse(response)['results']

      if results.empty?
        data =~ /@(-?\d+\.\d+),(-?\d+\.\d+)/
        lat = ::Regexp.last_match(1)
        lng = ::Regexp.last_match(2)
        return { latitude: lat.to_f, longitude: lng.to_f }
      else
        loc = results[0]['geometry']['location']
        raise GoogleApiError unless loc
      end

      { latitude: loc['lat'].to_f, longitude: loc['lng'].to_f }
    end
  end
end
