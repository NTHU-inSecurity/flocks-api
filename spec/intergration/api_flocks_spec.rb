# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Flock Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:accounts].each do |account_info|
      Flocks::Account.create(account_info)
    end
  end

  describe 'Getting flocks' do
    it 'HAPPY: should be able to get list of all flocks' do
      Flocks::CreateFlock.call(email: DATA[:accounts][0]['email'], flock_data: DATA[:flocks][0])
      Flocks::CreateFlock.call(email: DATA[:accounts][1]['email'], flock_data: DATA[:flocks][1])

      get 'api/v1/flocks'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single flock' do
      existing_flock = DATA[:flocks][0]

      Flocks::CreateFlock.call(email: DATA[:accounts][0]['email'], flock_data: existing_flock)
      id = Flocks::Flock.first.id

      get "/api/v1/flocks/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['attributes']['id']).must_equal id
      _(result['attributes']['destination_url']).must_equal existing_flock['destination_url']
    end

    it 'SAD: should return error if unknown flock requested' do
      get '/api/v1/flocks/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      Flocks::CreateFlock.call(email: DATA[:accounts][0]['email'], flock_data: DATA[:flocks][0])
      Flocks::CreateFlock.call(email: DATA[:accounts][1]['email'], flock_data: DATA[:flocks][1])

      get 'api/v1/flocks/2%20or%20id%3E0'
      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating New Flocks' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @flock_data = DATA[:flocks][0]
    end

    it 'HAPPY: should be able to create new flocks' do
      post 'api/v1/flocks', @flock_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      flock = Flocks::Flock.first

      _(created['id']).must_equal flock.id
      _(created['destination_url']).must_equal @flock_data['destination_url']
    end

    it 'SECURITY: should not create flock with mass assignment' do
      bad_data = @flock_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/flocks', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
