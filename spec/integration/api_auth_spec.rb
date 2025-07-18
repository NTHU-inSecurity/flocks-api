# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Authentication Routes' do
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    wipe_database

    # Setup signing keys for tests
    keypair = SignedRequest.generate_keypair
    SignedRequest.setup(keypair[:verify_key], keypair[:signing_key])
  end

  describe 'Account Authentication' do
    before do
      @account_data = DATA[:accounts][1]
      @account = Flocks::Account.create(@account_data)
    end

    it 'HAPPY: should authenticate valid credentials' do
      credentials = {
        username: @account_data['username'],
        password: @account_data['password']
      }

      signed = SignedRequest.sign(credentials)

      post 'api/v1/auth/authenticate', signed.to_json, @req_header
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
      account_info = response['data']['attributes']['account']['attributes']
      auth_token   = response['data']['attributes']['auth_token']

      _(account_info['username']).must_equal @account_data['username']
      _(auth_token).wont_be_nil
    end

    it 'BAD: should not authenticate invalid password' do
      credentials = {
        username: @account_data['username'],
        password: 'fakepassword'
      }

      signed = SignedRequest.sign(credentials)

      post 'api/v1/auth/authenticate', signed.to_json, @req_header
      result = JSON.parse(last_response.body)

      _(last_response.status).must_equal 403
      _(result['message'].downcase).must_include('invalid')
    end
  end
end
