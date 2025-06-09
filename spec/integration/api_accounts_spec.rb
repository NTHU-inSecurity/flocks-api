# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Account Handling' do
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    wipe_database

    # Setup signing keys for specs
    keypair = SignedRequest.generate_keypair
    SignedRequest.setup(keypair[:verify_key], keypair[:signing_key])
  end

  describe 'Account information' do
    it 'HAPPY: should be able to get details of a single account' do
      account_data = DATA[:accounts][1]
      account = Flocks::Account.create(account_data)

      # Authenticate
      credentials = {
        username: account_data['username'],
        password: account_data['password']
      }

      signed = SignedRequest.sign(credentials)
      post 'api/v1/auth/authenticate', signed.to_json, @req_header

      _(last_response.status).must_equal 200
      response = JSON.parse(last_response.body)
      auth_token = response.dig('data', 'attributes', 'auth_token')

      # Get account details
      auth_header = @req_header.merge('HTTP_AUTHORIZATION' => "Bearer #{auth_token}")
      get "/api/v1/accounts/#{account.username}", nil, auth_header

      _(last_response.status).must_equal 200

      attributes = JSON.parse(last_response.body).dig('data', 'attributes', 'account', 'attributes')
      _(attributes['username']).must_equal account.username
      _(attributes['salt']).must_be_nil
      _(attributes['password']).must_be_nil
      _(attributes['password_hash']).must_be_nil
    end
  end

  describe 'Account Creation' do
    before do
      @account_data = DATA[:accounts][1]
    end

    it 'HAPPY: should be able to create new accounts' do
      signed_data = SignedRequest.sign(@account_data)
      post 'api/v1/accounts', signed_data.to_json, @req_header

      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      account = Flocks::Account.first

      _(created['username']).must_equal @account_data['username']
      _(account.password?(@account_data['password'])).must_equal true
      _(account.password?('not_really_the_password')).must_equal false
    end

    it 'BAD: should not create account with illegal attributes' do
      bad_data = @account_data.clone
      bad_data['created_at'] = '1900-01-01'
      signed_bad_data = SignedRequest.sign(bad_data)

      post 'api/v1/accounts', signed_bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
