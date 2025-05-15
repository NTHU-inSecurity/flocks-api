# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Bird Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:accounts].each do |account_info|
      Flocks::Account.create(account_info)
    end

    Flocks::CreateFlock.call(username: DATA[:accounts][0]['username'], flock_data: DATA[:flocks][0])
  end

  describe 'Getting Birds' do
    before do
      @flock = Flocks::Flock.first
    end

    it 'HAPPY: should be able to get list of all birds in a flock' do
      accounts = Flocks::Account.all
      data = DATA[:birds].zip(accounts).map { |bird_data, account| bird_data.merge({ account: account }) }
      data.each { |d| Flocks::AddBirdToFlock.call(flock_id: @flock.id, bird_data: d) }

      get "api/v1/flocks/#{@flock.id}/birds"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 3
    end

    it 'HAPPY: should be able to get details of a single bird' do
      bird_data = DATA[:birds][0].merge({ account: Flocks::Account.first })
      bird = Flocks::AddBirdToFlock.call(flock_id: @flock.id, bird_data: bird_data)

      get "api/v1/flocks/#{@flock.id}/birds/#{bird.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body

      _(result['data']['message']).must_equal bird_data[:message]
      _(result['data']['account_id']).must_equal bird_data[:account_id]
    end

    it 'SAD: should return error if unknown bird requested' do
      get "/api/v1/flocks/#{@flock.id}/birds/foobar"

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent SQL injection in bird_id parameter' do
      bird_data = DATA[:birds][0].merge({ account: Flocks::Account.first })
      Flocks::AddBirdToFlock.call(flock_id: @flock.id, bird_data: bird_data)

      get "/api/v1/flocks/#{@flock.id}/birds/%27%20OR%20id%20LIKE%20%27%25%27%20--"
      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating New Birds' do
    before do
      @flock = Flocks::Flock.first
      @bird_data = DATA[:birds][0].merge({ account: Flocks::Account.first })
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new bird' do
      post "api/v1/flocks/#{@flock.id}/birds", @bird_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      bird = Flocks::Bird.first

      _(created['id']).must_equal bird.id
      _(created['message']).must_equal @bird_data['message']
      _(created['account_id']).must_equal @bird_data['account_id']
      _(created['flock_id']).must_equal @bird_data['flock_id']
    end

    it 'SECURITY: should not create birds with mass assignment' do
      bad_data = @bird_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/flocks/#{@flock.id}/birds", bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      assert_nil(last_response.headers['Location'])
    end
  end

  describe 'Updating Birds' do
    before do
      @flock = Flocks::Flock.first
      @bird_data = DATA[:birds][1].merge({ account: Flocks::Account.first })
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      Flocks::AddBirdToFlock.call(flock_id: @flock.id, bird_data: @bird_data)
      @bird = Flocks::Bird.first
    end
    
    it 'HAPPY: should be able to update the details of a single bird' do
      new_bird_data = { 
                        flock_id: @flock.id,
                        latitude: DATA[:birds][0]['latitude'],
                        longitude: DATA[:birds][0]['longitude'],
                        message: DATA[:birds][0]['message']
                      }

      post "api/v1/flocks/#{@flock.id}/birds/#{@bird.id}", new_bird_data.to_json, @req_header
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['data']['attributes']['latitude']).must_equal new_bird_data[:latitude]

    end
  end
end
