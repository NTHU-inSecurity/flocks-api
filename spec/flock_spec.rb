# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Project Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'PLACEHOLDER: GET projects endpoint should exist' do
    skip 'Implement GET /api/v1/projects endpoint'
    get 'api/v1/projects'
    _(last_response.status).must_equal 200
  end

  it 'PLACEHOLDER: GET single project endpoint should exist' do
    skip 'Implement GET /api/v1/projects/:id endpoint'
    get '/api/v1/projects/1'
    _(last_response.status).must_equal 200
  end

  it 'PLACEHOLDER: POST project endpoint should exist' do
    skip 'Implement POST /api/v1/projects endpoint'
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/projects', {}.to_json, req_header
    _(last_response.status).must_equal 201
  end

  it 'PLACEHOLDER: SAD path should return 404 for non-existent project' do
    skip 'Implement SAD path for GET /api/v1/projects/:id'
    get '/api/v1/projects/foobar'
    _(last_response.status).must_equal 404
  end
end