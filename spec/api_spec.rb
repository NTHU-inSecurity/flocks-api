# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'
require_relative '../app/controllers/app'
require_relative '../app/models/flock'

def app
  Flocks::Api
end

DATA = YAML.safe_load_file('db/seeds/flocks_seeds.yml')

describe 'Test Flocks Web API' do
  include Rack::Test::Methods

  before do
    # Wipe database before each test
    Dir.glob("#{Flocks::STORE_DIR}/*.txt").each { |filename| FileUtils.rm(filename) }
  end

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
    response_body = JSON.parse(last_response.body)
    _(response_body['message']).must_equal 'FlocksAPI up at /api/v1'
  end

  describe 'Handle flocks' do
    it 'HAPPY: should be able to get list of all flocks' do
      Flocks::Flock.new(DATA[0]).save
      Flocks::Flock.new(DATA[1]).save

      get 'api/v1/flocks'
      result = JSON.parse last_response.body
      _(last_response.status).must_equal 200
      _(result['flock_ids'].uniq.count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single flock' do
      Flocks::Flock.new(DATA[1]).save
      id = Dir.glob("#{Flocks::STORE_DIR}/*.txt").first.split(%r{[/.]})[-2]

      get "/api/v1/flocks/#{id}"
      result = JSON.parse last_response.body
      _(last_response.status).must_equal 200
      _(result['flock_id']).must_equal id
      _(result['destination_url']).must_equal DATA[1]['destination_url']
    end

    it 'HAPPY: should be able to create new flocks' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/flocks', DATA[0].to_json, req_header
      
      _(last_response.status).must_equal 201
      result = JSON.parse(last_response.body)
      _(result['Message']).must_equal 'Flock data saved'
      _(result).must_include 'id'
    end

    it 'HAPPY: should be able to get a specific bird by username' do
      flock = Flocks::Flock.new(DATA[0])
      flock.save
      flock_id = flock.flock_id
      username = DATA[0]['birds'].first['username']

      get "/api/v1/flocks/#{flock_id}/#{username}"
      
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result['username']).must_equal username
      _(result['message']).must_equal DATA[0]['birds'].first['message']
    end

    it 'SAD: should return error if unknown flock requested' do
      get '/api/v1/flocks/foobar'
      
      _(last_response.status).must_equal 404
      result = JSON.parse last_response.body
      _(result['message']).must_equal 'Flock not found'
    end

    it 'SAD: should return error if unknown bird requested' do
      flock = Flocks::Flock.new(DATA[0])
      flock.save
      flock_id = flock.flock_id

      get "/api/v1/flocks/#{flock_id}/nonexistent_user"
      

      _(last_response.status).must_equal 200
 
      result = last_response.body
      _(result.length).must_be :<, 5
    end
  end
end