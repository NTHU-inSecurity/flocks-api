# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Bird Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:flocks].each do |flock_data|
      Flocks::Flock.create(flock_data)
    end
  end

  describe 'Getting Birds' do
    before do
      @flock = Flocks::Flock.first
    end

    it 'HAPPY: should be able to get list of all birds in a flock' do
      DATA[:birds].each do |bird_data|
        @flock.add_bird(bird_data)
      end

      get "api/v1/flocks/#{@flock.id}/birds"
      _(last_response.status).must_equal 200
      
      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single bird' do
      bird_data = DATA[:birds][0]
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
      DATA[:birds].each do |bird_data|
        @flock.add_bird(bird_data)
      end

      get "/api/v1/flocks/#{@flock.id}/birds/%27%20OR%20username%20LIKE%20%27%25%27%20--"
      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating New Birds' do
    before do
      @flock = Flocks::Flock.first
      @bird_data = DATA[:birds][0]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new bird' do
      post "api/v1/flocks/#{@flock.id}/birds", @bird_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      bird = Flocks::Bird.first

      _(created['id']).must_equal bird.id
      _(created['username']).must_equal @bird_data['username']
      _(created['message']).must_equal @bird_data['message']
    end

    it 'SECURITY: should not create birds with mass assignment' do
      bad_data = @bird_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/flocks/#{@flock.id}/birds", bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      assert_nil(last_response.headers['Location'])
    end
  end
end
