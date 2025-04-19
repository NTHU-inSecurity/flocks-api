# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Bird Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    @flock = Flocks::Flock.create(destination_url: 'https://maps.app.goo.gl/test-location')
  end

  describe 'Getting birds' do
    it 'HAPPY: should be able to get list of all birds in a flock' do
      @flock.add_bird(username: 'user1', message: 'Hello', latitude: 24.0, longitude: 120.0, estimated_time: 1000)
      @flock.add_bird(username: 'user2', message: 'Hi', latitude: 25.0, longitude: 121.0, estimated_time: 2000)

      get "api/v1/flocks/#{@flock.id}/birds"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single bird' do
      bird_data = {
        username: 'test_user',
        message: 'Testing',
        latitude: 24.5,
        longitude: 120.5,
        estimated_time: 1500
      }
      bird = @flock.add_bird(bird_data)

      get "api/v1/flocks/#{@flock.id}/birds/#{bird.username}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['username']).must_equal bird_data[:username]
      _(result['data']['message']).must_equal bird_data[:message]
    end

    it 'SAD: should return error if unknown bird requested' do
      get "/api/v1/flocks/#{@flock.id}/birds/foobar"

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent SQL injection in username parameter' do
      @flock.add_bird(username: 'legituser', message: 'Normal', latitude: 24.0, longitude: 120.0, estimated_time: 1000)

      get "/api/v1/flocks/#{@flock.id}/birds/legituser'%20OR%20'1'='1"
      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating Birds' do
    before do
      @bird_data = {
        username: 'new_user',
        message: 'New message',
        latitude: 24.0,
        longitude: 120.0,
        estimated_time: 1000
      }
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new birds' do
      post "api/v1/flocks/#{@flock.id}/birds", @bird_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0
      created = JSON.parse(last_response.body)['data']
      bird = Flocks::Bird.first
      _(bird.username).must_equal @bird_data[:username]
      _(bird.message).must_equal @bird_data[:message]
      _(created['username']).must_equal @bird_data[:username]
      _(created['message']).must_equal @bird_data[:message]
    end

    it 'SECURITY: should not create birds with mass assignment' do
      bad_data = @bird_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/flocks/#{@flock.id}/birds", bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
