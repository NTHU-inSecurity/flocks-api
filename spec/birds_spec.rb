# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Bird Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:flocks].each do |flock_data|
      Flocks::Flock.create(flock_data)
    end
  end

  it 'HAPPY: should be able to get list of all birds' do
    flock = Flocks::Flock.first
    DATA[:birds].each do |bird|
      flock.add_bird(bird)
    end
    
    get "api/v1/flocks/#{flock.id}/birds"
    _(last_response.status).must_equal 200
  end

  it 'PLACEHOLDER: GET single document endpoint should exist' do
    skip 'Implement GET /api/v1/documents/:id endpoint'
    get '/api/v1/documents/1'
    _(last_response.status).must_equal 200
  end

  it 'PLACEHOLDER: POST document endpoint should exist' do
    skip 'Implement POST /api/v1/documents endpoint'
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/documents', {}.to_json, req_header
    _(last_response.status).must_equal 201
  end

  it 'PLACEHOLDER: SAD path should return 404 for non-existent document' do
    skip 'Implement SAD path for GET /api/v1/documents/:id'
    get '/api/v1/documents/foobar'
    _(last_response.status).must_equal 404
  end
end