# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Bird Handling' do
  include Rack::Test::Methods

  def auth_header_for(account)
    token = AuthToken.create(account)
    {
      'CONTENT_TYPE' => 'application/json',
      'HTTP_AUTHORIZATION' => "Bearer #{token}"
    }
  end

  before do
    wipe_database
    @accounts = DATA[:accounts].map { |acc| Flocks::Account.create(acc) }

    @flock = @accounts[0].add_created_flock(DATA[:flocks][0])

    @auth_header = auth_header_for(@accounts[0])
  end

  describe 'Getting Birds' do
    it 'HAPPY: should be able to get list of all birds in a flock' do
      DATA[:birds][1..2].zip(@accounts[1..2]).each do |bird_data, account|
        enriched = bird_data.transform_keys(&:to_sym).merge(account_id: account.id)
        Flocks::AddBirdToFlock.call(flock_id: @flock.id, bird_data: enriched)
      end

      get "api/v1/flocks/#{@flock.id}/birds", {}, @auth_header
      _(last_response.status).must_equal 200
      result = JSON.parse(last_response.body)
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single bird' do
      account = @accounts[1]
      bird_data = DATA[:birds][1].transform_keys(&:to_sym).merge(account_id: account.id)
      Flocks::AddBirdToFlock.call(flock_id: @flock.id, bird_data: bird_data)

      get "api/v1/flocks/#{@flock.id}/birds", {}, @auth_header
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)
      bird_info = result['data'].first['data']
      included_info = result['data'].first['included']

      _(bird_info['attributes']['message']).must_equal bird_data[:message]
      _(included_info.dig('account', 'attributes', 'username')).must_equal account.username
    end

    it 'SAD: should return error if unknown bird requested' do
      get "/api/v1/flocks/#{@flock.id}/birds/foobar", {}, @auth_header
      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent SQL injection in bird_id parameter' do
      get "/api/v1/flocks/#{@flock.id}/birds/%27%20OR%20id%20LIKE%20%27%25%27%20--", {}, @auth_header
      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating New Birds' do
    before do
      @account = @accounts[2]
      @flock = @accounts[1].add_created_flock(DATA[:flocks][1])

      @bird_data = {
        message: DATA[:birds][0]['message'],
        latitude: DATA[:birds][0]['latitude'],
        longitude: DATA[:birds][0]['longitude']
      }

      @auth_header = auth_header_for(@account)
    end

    it 'HAPPY: should be able to create new bird' do
      post "api/v1/flocks/#{@flock.id}/birds", @bird_data.to_json, @auth_header

      if last_response.status != 201
        puts "\n[DEBUG] Server returned status #{last_response.status}"
        puts "[DEBUG] Response body:\n#{last_response.body}"
      end

      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0
      bird_attrs = JSON.parse(last_response.body).dig('data', 'relationships', 'birds', 0, 'data', 'attributes')
      _(bird_attrs['message']).must_equal @bird_data[:message]
    end

    it 'SECURITY: should not create birds with mass assignment' do
      bad_data = @bird_data.merge(created_at: '1900-01-01')

      post "api/v1/flocks/#{@flock.id}/birds", bad_data.to_json, @auth_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
