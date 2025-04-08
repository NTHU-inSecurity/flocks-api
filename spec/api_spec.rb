require 'rack/test'
require 'json'
require 'fileutils'
require_relative '../app/controllers/app'
require_relative '../app/models/flock'

describe 'Flocks API' do
  include Rack::Test::Methods

  def app
    Flocks::Api
  end

  # Since we already have seed data loaded, we don't need to set up
  # additional test data before running tests
  before(:all) do
    # Ensure the test directory exists
    FileUtils.mkdir_p('db/local')
  end

  # HAPPY tests
  describe 'HAPPY tests' do
    it 'should return successful response for root route' do
      get '/'
      expect(last_response.status).to eq 200
      response_body = JSON.parse(last_response.body)
      expect(response_body).to have_key('message')
    end

    it 'should create a new resource successfully (POST method)' do
      new_flock = { 
        destination_url: 'https://maps.app.goo.gl/new-location',
        birds: [
          {
            username: 'test_user',
            message: 'Coming soon',
            latitude: 24.790000,
            longitude: 120.980000,
            estimated_time: 1200
          }
        ]
      }

      post '/api/v1/flocks', new_flock.to_json, { 'CONTENT_TYPE' => 'application/json' }
      
      expect(last_response.status).to eq 201
      response_body = JSON.parse(last_response.body)
      expect(response_body).to have_key('Message')
      expect(response_body).to have_key('id')
    end

    it 'should get a single resource successfully (GET method)' do
      # Get the first flock_id from the list of all flocks
      get '/api/v1/flocks'
      all_flocks = JSON.parse(last_response.body)
      flock_id = all_flocks['flock_ids'].first
      
      # Use that flock_id to test getting a single resource
      get "/api/v1/flocks/#{flock_id}"
      
      expect(last_response.status).to eq 200
      response_body = JSON.parse(last_response.body)
      expect(response_body).to have_key('flock_id')
      expect(response_body).to have_key('birds')
    end

    it 'should get a list of resources successfully (GET method)' do
      get '/api/v1/flocks'
      
      expect(last_response.status).to eq 200
      response_body = JSON.parse(last_response.body)
      expect(response_body).to have_key('flock_ids')
      expect(response_body['flock_ids']).to be_an(Array)
      expect(response_body['flock_ids'].length).to be > 0
    end
  end

  # SAD tests
  describe 'SAD tests' do
    it 'should fail when trying to GET a non-existent resource' do
      get '/api/v1/flocks/nonexistent_flock'
      
      expect(last_response.status).to eq 404
      response_body = JSON.parse(last_response.body)
      expect(response_body).to have_key('message')
      expect(response_body['message']).to include('not found')
    end
  end
end