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

  it 'HAPPY: should be able to get list of all flocks' do
    flock = Flocks::Flock.first
    DATA[:birds].each do |bird|
      flock.add_bird(bird)
    end

    get "api/v1/flocks/#{flock.id}/birds"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single bird' do
    bird_data = DATA[:birds][1]
    flock = Flocks::Flock.first

    bird = flock.add_bird(bird_data).save

    get "/api/v1/flocks/#{flock.id}/birds/#{bird.username}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal bird.id
    _(result['data']['attributes']['username']).must_equal bird_data['username']
  end

  it 'SAD: should return error if unknown bird requested' do
    flock = Flocks::Flock.first
    get "/api/v1/flocks/#{flock.id}/birds/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new birds' do
    flock = Flocks::Flock.first
    bird_data = DATA[:birds][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/flocks/#{flock.id}/birds",
         bird_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.headers['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    bird = Flocks::Bird.first

    _(created['id']).must_equal bird.id
    _(created['username']).must_equal bird_data['username']
    _(created['message']).must_equal bird_data['message']
    _(created['latitude']).must_equal bird_data['latitude']
    _(created['longitude']).must_equal bird_data['longitude']
    _(created['estimated_time']).must_equal bird_data['estimated_time']
  end
end
