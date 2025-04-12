# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Document Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    # 創建測試項目，未來文檔會關聯到項目
    # @project = Flocks::Project.create(DATA[:projects][0])
  end

  it 'PLACEHOLDER: GET documents endpoint should exist' do
    skip 'Implement GET /api/v1/documents endpoint'
    get 'api/v1/documents'
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