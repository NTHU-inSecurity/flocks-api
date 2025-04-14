# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Flock Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all flocks' do
    Flocks::Flock.create(DATA[:flocks][0]).save_changes
    Flocks::Flock.create(DATA[:flocks][1]).save_changes

    get 'api/v1/flocks'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single flock' do
    existing_flock = DATA[:flocks][1]
    Flocks::Flock.create(existing_flock).save_changes
    flock_id = Flocks::Flock.first.id

    get "/api/v1/flocks/#{flock_id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal flock_id
    _(result['data']['attributes']['destination_url']).must_equal existing_flock['destination_url']
  end

  it 'SAD: should return error if unknown flock requested' do
    get '/api/v1/flocks/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new flocks' do
    existing_flock = DATA[:flocks][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/flocks', existing_flock.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.headers['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    flock = Flocks::Flock.first

    _(created['id']).must_equal flock.id
    _(created['destination_url']).must_equal existing_flock['destination_url']
  end
end