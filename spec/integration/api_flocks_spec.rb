# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Flock Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    @account_data = DATA[:accounts][0]
    @account = Flocks::Account.create(@account_data)
    token = AuthToken.create(@account)
    @auth_header = {
      'CONTENT_TYPE' => 'application/json',
      'HTTP_AUTHORIZATION' => "Bearer #{token}"
    }
  end

  describe 'Getting flocks of a single account' do
    it 'HAPPY: should be able to get list of all flocks' do
      flock_data_0 = Flocks::Helper.deep_symbolize(DATA[:flocks][0])
      flock_data_1 = Flocks::Helper.deep_symbolize(DATA[:flocks][1])

      @account.add_created_flock(flock_data_0)
      @account.add_created_flock(flock_data_1)

      get 'api/v1/flocks', {}, @auth_header
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single flock' do
      flock_data = Flocks::Helper.deep_symbolize(DATA[:flocks][0])
      created = @account.add_created_flock(flock_data)
      id = created.id

      get "api/v1/flocks/#{id}", {}, @auth_header
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)
      _(result['attributes']['id']).must_equal id
      _(result['attributes']['destination_url']).must_equal DATA[:flocks][0]['destination_url']
    end

    it 'SAD: should return error if unknown flock requested' do
      get '/api/v1/flocks/foobar', {}, @auth_header
      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      flock_data = Flocks::Helper.deep_symbolize(DATA[:flocks][0])
      @account.add_created_flock(flock_data)
      get 'api/v1/flocks/2%20or%20id%3E0', {}, @auth_header
      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating New Flocks' do
    before do
      @flock_data = Flocks::Helper.deep_symbolize(DATA[:flocks][0])
    end

    it 'HAPPY: should be able to create new flocks' do
      post 'api/v1/flocks', @flock_data.to_json, @auth_header

      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['destination_url']).must_equal @flock_data[:destination_url]
    end

    it 'SECURITY: should not create flock with mass assignment' do
      bad_data = @flock_data.clone
      bad_data[:created_at] = '1900-01-01'

      post 'api/v1/flocks', bad_data.to_json, @auth_header
      _(last_response.status).must_equal 400
    end
  end
end
